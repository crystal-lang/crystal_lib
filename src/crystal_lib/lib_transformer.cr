class CrystalLib::LibTransformer < Crystal::Transformer
  def initialize
    @includes = [] of Crystal::Attribute
    @pending_definitions = [] of Crystal::ASTNode
  end

  def transform(node : Crystal::Attribute)
    if node.name == "Include"
      @includes << node
      Crystal::Nop.new
    else
      node
    end
  end

  def transform(node : Crystal::LibDef)
    headers = @includes.map { |inc| "#include <#{(inc.args[0] as Crystal::StringLiteral).value}>" }.join "\n"
    nodes = CrystalLib::Parser.parse(headers)

    node.body = node.body.transform CrystalLib::LibBodyTransformer.new(nodes)

    node
  end
end
