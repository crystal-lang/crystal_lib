require "compiler/crystal/*"
require "compiler/crystal/syntax/parser"
require "compiler/crystal/syntax/transformer"
require "compiler/crystal/semantic/*"

class CrystalLib::LibBodyTransformer < Crystal::Transformer
  def initialize(nodes : Array(CrystalLib::ASTNode))
    @nodes = nodes.index_by &.name
    @mapper = TypeMapper.new
  end

  def transform(node : Crystal::FunDef)
    func = find_node node.real_name
    raise "can't find function #{node.real_name}" unless func.is_a?(CrystalLib::Function)

    node.args = func.args.map_with_index do |arg, i|
      Crystal::Arg.new(arg.name.empty? ? "x#{i}" : arg.name, restriction: map_type(arg.type))
    end
    return_type = map_type(func.return_type)

    unless void?(return_type)
      node.return_type = return_type
    end

    node.varargs = func.variadic?

    check_pending_definitions(node)
  end

  def transform(node : Crystal::Assign)
    match = find_node(node.value.to_s)
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
    @mapper.map(type)
  end

  def find_node(name)
    @nodes[name]?
  end

  def check_pending_definitions(node)
    return node if @mapper.pending_definitions.empty?

    nodes = @mapper.pending_definitions.dup
    nodes << node

    @mapper.pending_definitions.clear

    Crystal::Expressions.new(nodes)
  end

  def void?(node)
    node.is_a?(Crystal::Path) && node.names.size == 1 && node.names.first == "Void"
  end
end
