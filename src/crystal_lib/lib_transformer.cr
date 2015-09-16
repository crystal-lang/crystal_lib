class CrystalLib::LibTransformer < Crystal::Transformer
  def initialize
    @includes = [] of Crystal::Attribute
    @include_flags = [] of Crystal::Attribute
    @pending_definitions = [] of Crystal::ASTNode
  end

  def transform(node : Crystal::Attribute)
    case node.name
    when "Include"
      @includes << node
      Crystal::Nop.new
    when "IncludeFlags"
      @include_flags << node
      Crystal::Nop.new
    else
      node
    end
  end

  def transform(node : Crystal::LibDef)
    headers = @includes.map { |inc| "#include <#{(inc.args[0] as Crystal::StringLiteral).value}>" }.join "\n"
    flags = @include_flags.flat_map { |inc| (inc.args[0] as Crystal::StringLiteral).value.split(' ') }
    nodes = CrystalLib::Parser.parse(headers, flags)

    # nodes.each do |node|
    #   puts node
    # end

    node.body = node.body.transform CrystalLib::LibBodyTransformer.new(nodes)

    node
  end
end
