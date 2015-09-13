require "compiler/crystal/**"

class CrystalLib::LibBodyTransformer < Crystal::Transformer
  def initialize(nodes : Array(CrystalLib::ASTNode))
    @nodes = nodes.index_by &.name
    @pending_definitions = [] of Crystal::ASTNode
    @generated = {} of typeof(object_id) => Crystal::ASTNode
  end

  def transform(node : Crystal::FunDef)
    func = find_function node.real_name
    raise "can't find function #{node.real_name}" unless func

    node.args = func.args.map_with_index do |arg, i|
      arg_type = map_type(arg.type)
      Crystal::Arg.new(arg.name.empty? ? "x#{i}" : arg.name, restriction: arg_type)
    end
    node.return_type = map_type(func.return_type)

    check_pending_definitions(node)
  end

  def transform(node : Crystal::Assign)
    name = (node.value as Crystal::Path).names.first
    match = find_node(name)
    case match
    when Define
      node.value = Crystal::Parser.parse(match.value)
    else
      raise "Unexpected type for constant: #{node}, #{match}, #{match.class}"
    end
    node
  end

  def map_type(type)
    @generated[type.object_id] ||= map_type_internal(type)
  end

  def map_type_internal(type : PrimitiveType)
    case type.kind
    when PrimitiveType::Kind::Char_S
      path ["LibC", "Char"]
    when PrimitiveType::Kind::Int
      path ["LibC", "Int"]
    when PrimitiveType::Kind::UChar
      path ["LibC", "UInt8"]
    else
      raise "Unsupported primitive kind: #{type.kind}"
    end
  end

  def map_type_internal(type : PointerType)
    pointee_type = type.type

    # Check the case of a pointer to an opaque struct
    if opaque_type = opaque_type?(pointee_type)
      alias_name = opaque_type.name.capitalize
      declare_alias(alias_name, pointer_type(path("Void")))
      return Crystal::Path.new(alias_name)
    end

    pointer_type(map_type(type.type))
  end

  def map_type_internal(type : TypedefType)
    map_type(type.type)
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
    Crystal::Generic.new(Crystal::Path.new("Pointer"), element_type)
  end

  def path(path)
    Crystal::Path.new(path)
  end

  def declare_alias(name, type)
    @pending_definitions << Crystal::TypeDef.new(name, type)
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

  def find_function(name)
    match = find_node(name)
    match.is_a?(Function) ? match : nil
  end

  def find_node(name)
    @nodes[name]?
  end
end
