require "compiler/crystal/**"

class CrystalLib::LibBodyTransformer < Crystal::Transformer
  def initialize(nodes : Array(CrystalLib::ASTNode))
    @nodes = nodes.index_by &.name
    @pending_definitions = [] of Crystal::ASTNode
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

  def map_type(type : PrimitiveType)
    case type.kind
    when PrimitiveType::Kind::Char_S
      Crystal::Path.new(["LibC", "Char"])
    when PrimitiveType::Kind::Int
      Crystal::Path.new(["LibC", "Int"])
    when PrimitiveType::Kind::UChar
      Crystal::Path.new(["LibC", "UInt8"])
    else
      raise "Unsupported primitive kind: #{type.kind}"
    end
  end

  def map_type(type : PointerType)
    Crystal::Generic.new(Crystal::Path.new("Pointer"), map_type(type.type))
  end

  def map_type(type : TypedefType)
    other_type = type.type
    if other_type.is_a?(NodeRef)
      other_node = other_type.node
      if other_node.is_a?(StructOrUnion)
        if other_node.fields.empty?
          alias_name = type.name.capitalize
          declare_alias(alias_name, Crystal::Path.new("Void"))
          return Crystal::Path.new(alias_name)
        end
      end
    end
    map_type(type.type)
  end

  def map_type(type)
    raise "Unsupported: #{type}, #{type.class}"
  end

  def declare_alias(name, type)
    @pending_definitions << Crystal::Alias.new(name, type)
  end

  def check_pending_definitions(node)
    if @pending_definitions.empty?
      node
    else
      nodes = typeof(@pending_definitions).new
      nodes.concat @pending_definitions
      nodes << node

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
