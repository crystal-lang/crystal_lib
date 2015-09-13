require "compiler/crystal/**"

class CrystalLib::LibBodyTransformer < Crystal::Transformer
  def initialize(nodes : Array(CrystalLib::ASTNode))
    @nodes = nodes.index_by &.name
    @pending_definitions = [] of Crystal::ASTNode
    @generated = {} of typeof(object_id) => Crystal::ASTNode
  end

  def transform(node : Crystal::FunDef)
    func = find_node node.real_name
    raise "can't find function #{node.real_name}" unless func.is_a?(CrystalLib::Function)

    node.args = func.args.map_with_index do |arg, i|
      arg_type = map_type(arg.type)
      Crystal::Arg.new(arg.name.empty? ? "x#{i}" : arg.name, restriction: arg_type)
    end
    node.return_type = map_type(func.return_type)
    node.varargs = func.variadic?

    check_pending_definitions(node)
  end

  def transform(node : Crystal::Assign)
    name = node.value.to_s
    match = find_node(name)
    case match
    when Define
      node.value = Crystal::Parser.parse(match.value)
    else
      raise "Unexpected type for constant: #{node}, #{match}, #{match.class}"
    end
    node
  end

  def transform(node : Crystal::ExternalVar)
    name = node.real_name || node.name

    match = find_node(name)
    raise "can't find variable #{name}" unless match.is_a?(CrystalLib::Var)

    node.type_spec = map_type(match.type)
    check_pending_definitions(node)
  end

  def map_type(type)
    @generated[type.object_id] ||= map_type_internal(type)
  end

  def map_type_internal(type : PrimitiveType)
    case type.kind
    when PrimitiveType::Kind::Void
      path "Void"
    when PrimitiveType::Kind::Char_S
      path ["LibC", "Char"]
    when PrimitiveType::Kind::Int
      path ["LibC", "Int"]
    when PrimitiveType::Kind::Short
      path ["LibC", "Short"]
    when PrimitiveType::Kind::UChar
      path ["LibC", "UInt8"]
    when PrimitiveType::Kind::Long
      path ["LibC", "Long"]
    when PrimitiveType::Kind::LongLong
      path ["LibC", "LongLong"]
    when PrimitiveType::Kind::UInt
      path ["LibC", "UInt"]
    when PrimitiveType::Kind::UShort
      path ["LibC", "UShort"]
    when PrimitiveType::Kind::ULong
      path ["LibC", "ULong"]
    when PrimitiveType::Kind::ULongLong
      path ["LibC", "ULongLong"]
    when PrimitiveType::Kind::Float
      path ["LibC", "Float"]
    when PrimitiveType::Kind::Double
      path ["LibC", "Double"]
    else
      raise "Unsupported primitive kind: #{type.kind}"
    end
  end

  def map_type_internal(type : PointerType)
    pointee_type = type.type

    # Check the case of a pointer to an opaque struct
    if opaque_type = opaque_type?(pointee_type)
      alias_name = opaque_type.name.capitalize
      return declare_typedef(alias_name, pointer_type(path("Void")))
    end

    pointer_type(map_type(type.type))
  end

  def map_type_internal(type : TypedefType)
    mapped = map_type(type.type)
    declare_alias(type.name, mapped)
  end

  def map_type_internal(type : FunctionType)
    inputs = type.inputs.map { |input| map_type(input) as Crystal::ASTNode }
    output = map_type(type.output)
    Crystal::Fun.new(inputs, output)
  end

  def map_type_internal(type : ConstantArrayType)
    element_type = map_type(type.type)
    generic(path("StaticArray"), [element_type, Crystal::NumberLiteral.new(type.size)] of Crystal::ASTNode)
  end

  def map_type_internal(type)
    raise "Unsupported: #{type}, #{type.class}"
  end

  def opaque_type?(type)
    return unless type.is_a?(TypedefType)

    other_type = type.type
    return unless other_type.is_a?(NodeRef)

    other_node = other_type.node
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

  def declare_alias(name, type)
    crystal_name = crystal_name(name)
    @pending_definitions << Crystal::Alias.new(crystal_name, type)
    path(crystal_name)
  end

  def declare_typedef(name, type)
    crystal_name = crystal_name(name)
    @pending_definitions << Crystal::TypeDef.new(crystal_name, type)
    path(crystal_name)
  end

  def check_pending_definitions(node)
    if @pending_definitions.empty?
      node
    else
      nodes = typeof(@pending_definitions).new
      nodes.concat @pending_definitions
      nodes << node

      @pending_definitions.clear

      Crystal::Expressions.new(nodes)
    end
  end

  def find_node(name)
    @nodes[name]?
  end

  def crystal_name(name)
    name.camelcase
  end
end
