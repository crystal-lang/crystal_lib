class CrystalLib::TypeMapper
  getter pending_definitions

  def initialize
    @pending_definitions = [] of Crystal::ASTNode
    @generated = {} of typeof(object_id) => Crystal::ASTNode
  end

  def map(type)
    @generated[type.object_id] ||= map_internal(type)
  end

  def map_internal(type : PrimitiveType)
    case type.kind
    when PrimitiveType::Kind::Void
      path "Void"
    when PrimitiveType::Kind::Char_S
      path ["LibC", "Char"]
    when PrimitiveType::Kind::UChar
      path ["LibC", "UInt8"]
    when PrimitiveType::Kind::Int,
         PrimitiveType::Kind::Short,
         PrimitiveType::Kind::Long,
         PrimitiveType::Kind::LongLong,
         PrimitiveType::Kind::UInt,
         PrimitiveType::Kind::UShort,
         PrimitiveType::Kind::ULong,
         PrimitiveType::Kind::ULongLong,
         PrimitiveType::Kind::Float,
         PrimitiveType::Kind::Double
      path ["LibC", type.kind.to_s]
    else
      raise "Unsupported primitive kind: #{type.kind}"
    end
  end

  def map_internal(type : PointerType)
    pointee_type = type.type

    # Check the case of a pointer to an opaque struct
    if opaque_type = opaque_typedef?(pointee_type)
      typedef_name = opaque_type.name.capitalize
      return declare_typedef(typedef_name, pointer_type(path("Void")))
    end

    pointer_type(map(type.type))
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
      return map(internal_node)
    end

    mapped = map(internal_type)
    declare_alias(type.name, mapped)
  end

  def map_internal(type : FunctionType)
    inputs = type.inputs.map { |input| map(input) as Crystal::ASTNode }
    output = map(type.output)
    Crystal::Fun.new(inputs, output)
  end

  def map_internal(type : ConstantArrayType)
    element_type = map(type.type)
    generic(path("StaticArray"), [element_type, Crystal::NumberLiteral.new(type.size)] of Crystal::ASTNode)
  end

  def map_internal(type : NodeRef)
    map(type.node)
  end

  def map_internal(type : CrystalLib::Enum)
    enum_name = crystal_type_name(check_anonymous_name(type.name))
    enum_members = type.values.map do |value|
      Crystal::Arg.new(crystal_type_name(value.name), default_value: Crystal::NumberLiteral.new(value.value)) as Crystal::ASTNode
    end
    enum_def = Crystal::EnumDef.new(enum_name, enum_members)
    @pending_definitions << enum_def
    path(enum_name)
  end

  def map_internal(type : CrystalLib::StructOrUnion)
    struct_name = crystal_type_name(check_anonymous_name(type.unscoped_name))
    klass = type.kind == :struct ? Crystal::StructDef : Crystal::UnionDef
    fields = type.fields.map do |field|
      Crystal::Arg.new(crystal_field_name(field.name), restriction: map(field.type)) as Crystal::ASTNode
    end
    struct_def = klass.new(struct_name, fields)
    @pending_definitions << struct_def
    path(struct_name)
  end

  def map_internal(type : UnexposedType)
    path("Void")
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
    name.empty? ? @typedef_name.not_nil! : name
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

  def crystal_type_name(name)
    name.camelcase
  end

  def crystal_field_name(name)
    name.underscore
  end
end