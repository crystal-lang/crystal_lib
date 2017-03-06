class CrystalLib::TypeMapper
  record PendingStruct,
    crystal_node : Crystal::CStructOrUnionDef,
    clang_type : CrystalLib::StructOrUnion,
    original_name : String

  getter pending_definitions

  @typedef_name : String?

  def initialize(@prefix_matcher : PrefixMatcher? = nil)
    @pending_definitions = [] of Crystal::ASTNode
    @pending_structs = [] of PendingStruct
    @generated = {} of UInt64 => Crystal::ASTNode

    # When completing a struct's fields we keep that struct and the field name in
    # case we find a nested struct, such as in:#
    #
    # struct foo {
    #   struct {
    #     int x;
    #   } point;
    # };
    #
    # In that case we want to generate Foo and FooPoint structs.
    @structs_stack = [] of {PendingStruct, String}
  end

  def map(type)
    map_non_recursive(type).tap { expand_pending_structs }
  end

  def map_non_recursive(type)
    @generated[type.object_id] ||= map_internal(type)
  end

  def map_internal(type : PrimitiveType)
    case type.kind
    when .void?
      path "Void"
    when .char_s?, .s_char?
      path ["LibC", "Char"]
    when .u_char?
      path ["UInt8"]
    when PrimitiveType::Kind::Bool,
         PrimitiveType::Kind::Int,
         PrimitiveType::Kind::Short,
         PrimitiveType::Kind::Long,
         PrimitiveType::Kind::LongLong,
         PrimitiveType::Kind::UInt,
         PrimitiveType::Kind::UShort,
         PrimitiveType::Kind::ULong,
         PrimitiveType::Kind::ULongLong,
         PrimitiveType::Kind::Float,
         PrimitiveType::Kind::Double,
         PrimitiveType::Kind::LongDouble,
         PrimitiveType::Kind::WChar,
         PrimitiveType::Kind::VaList
      path ["LibC", type.kind.to_s]
    else
      raise "Unsupported primitive kind: #{type.kind}"
    end
  end

  def map_internal(type : PointerType)
    pointee_type = type.type

    # Check the case of a pointer to an opaque struct
    if opaque_type = opaque_typedef?(pointee_type)
      return declare_typedef(opaque_type.name, pointer_type(path("Void")))
    end

    pointer_type(map_non_recursive(type.type))
  end

  def map_internal(type : BlockPointerType)
    pointer_type(map_non_recursive(type.type))
  end

  def map_internal(type : TypedefType)
    if type.name == "size_t"
      return path ["LibC", "SizeT"]
    end

    # Check the case of a typedef to a pointer to an opaque struct
    internal_type = type.type
    if internal_type.is_a?(PointerType) && opaque?(internal_type.type)
      return declare_typedef(type.name, pointer_type(path("Void")))
    end

    if internal_type.is_a?(NodeRef)
      internal_node = internal_type.node
      @typedef_name = type.name
      mapped = map_non_recursive(internal_node)
      @typedef_name = nil

      if internal_type.node.name.empty? || type.name == internal_type.node.unscoped_name
        return mapped
      end

      declare_typedef(type.name, mapped)
    else
      mapped = map_non_recursive(internal_type)
      declare_alias(type.name, mapped)
    end
  end

  def map_internal(type : FunctionType)
    inputs = type.inputs.map { |input| map_non_recursive(input).as(Crystal::ASTNode) }
    output = map_non_recursive(type.output)
    Crystal::ProcNotation.new(inputs, output)
  end

  def map_internal(type : ConstantArrayType)
    element_type = map_non_recursive(type.type)
    generic(path("StaticArray"), [element_type, Crystal::NumberLiteral.new(type.size)] of Crystal::ASTNode)
  end

  def map_internal(type : IncompleteArrayType)
    element_type = map_non_recursive(type.type)
    pointer_type(element_type)
  end

  def map_internal(type : NodeRef)
    map_non_recursive(type.node)
  end

  def map_internal(type : CrystalLib::Enum)
    enum_name = crystal_type_name(check_anonymous_name(type.name))
    enum_members = type.values.map do |value|
      Crystal::Arg.new(crystal_type_name(value.name), default_value: Crystal::NumberLiteral.new(value.value)).as(Crystal::ASTNode)
    end
    enum_def = Crystal::EnumDef.new(path([enum_name]), enum_members)
    @pending_definitions << enum_def
    path(enum_name)
  end

  def map_internal(type : CrystalLib::StructOrUnion)
    untouched_struct_name = check_anonymous_name(type.unscoped_name)
    struct_name = crystal_type_name(untouched_struct_name)

    if type.fields.empty?
      # For an empty struct we just return an alias to Void
      struct_def = Crystal::Alias.new(struct_name, path(["Void"]))
    else
      struct_def = Crystal::CStructOrUnionDef.new(struct_name, union: type.kind == :union)

      # Leave struct body for later, because of possible recursiveness
      @pending_structs << PendingStruct.new(struct_def, type, untouched_struct_name)
    end

    @pending_definitions << struct_def unless @generated.has_key?(type.object_id)

    path(struct_name)
  end

  def map_internal(type : UnexposedType)
    path("Void")
  end

  def map_internal(type : ErrorType)
    raise "Couldn't import type: #{type}"
  end

  def map_internal(type)
    raise "Unsupported type: #{type}, #{type.class}"
  end

  def opaque_typedef?(type)
    type.is_a?(TypedefType) && opaque?(type.type) ? type : nil
  end

  def opaque?(type)
    return unless type.is_a?(NodeRef)

    other_node = type.node
    (other_node.is_a?(StructOrUnion) && other_node.fields.empty?) ? type : nil
  end

  def pointer_type(element_type)
    generic(path("Pointer"), element_type)
  end

  def generic(name, args)
    Crystal::Generic.new(name, args)
  end

  def path(path)
    Crystal::Path.new(path)
  end

  def check_anonymous_name(name)
    return name unless name.empty?

    typedef_name = @typedef_name
    return typedef_name if typedef_name

    unless @structs_stack.empty?
      pending_struct, name = @structs_stack.last
      return "#{pending_struct.original_name}_#{name}"
    end

    raise "Bug: missing struct name"
  end

  def declare_alias(name, type)
    crystal_name = crystal_type_name(name)
    @pending_definitions << Crystal::Alias.new(crystal_name, type)
    path(crystal_name)
  end

  def declare_typedef(name, type)
    crystal_name = crystal_type_name(name)
    @pending_definitions << Crystal::TypeDef.new(crystal_name, type)
    path(crystal_name)
  end

  def expand_pending_structs
    while pending_struct = @pending_structs.pop?
      fields = pending_struct.clang_type.fields.map do |field|
        @structs_stack.push({pending_struct, field.name})
        arg = Crystal::Arg.new(crystal_field_name(field.name), restriction: map(field.type)).as(Crystal::ASTNode)
        @structs_stack.pop
        arg
      end
      pending_struct.crystal_node.body = Crystal::Expressions.from(fields)
    end
  end

  def crystal_type_name(name)
    name = match_prefix(name)

    underscore_index = nil
    name.each_char_with_index do |char, i|
      break if char != '_'
      underscore_index = i
    end

    if underscore_index
      name = name[underscore_index + 1..-1]
    end

    name = name.underscore.camelcase

    if underscore_index
      name = String.build do |str|
        str << 'X'
        (underscore_index + 1).times { str << '_' }
        str << name
      end
    end

    name
  end

  def crystal_arg_name(name)
    crystal_field_name(name)
  end

  def crystal_fun_name(name)
    crystal_field_name(name)
  end

  def crystal_field_name(name)
    name = match_prefix(name).underscore
    name = "_end" if name == "end"
    name
  end

  def match_prefix(name)
    @prefix_matcher.try(&.match(name)) || name
  end
end
