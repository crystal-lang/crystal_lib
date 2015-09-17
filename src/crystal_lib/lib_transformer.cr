class CrystalLib::LibTransformer < Crystal::Transformer
  def initialize
    @includes = [] of Crystal::Attribute
    @pending_definitions = [] of Crystal::ASTNode
  end

  def transform(node : Crystal::Attribute)
    case node.name
    when "Include"
      @includes << node
      Crystal::Nop.new
    else
      node
    end
  end

  def transform(node : Crystal::LibDef)
    headers, flags = process_includes
    nodes = CrystalLib::Parser.parse(headers, flags)
    node.body = node.body.transform CrystalLib::LibBodyTransformer.new(nodes)
    node
  end

  def process_includes
    headers = StringIO.new
    flags = [] of String

    @includes.each do |attr|
      attr.args.each do |arg|
        case arg
        when Crystal::StringLiteral
          headers << "#include <" << arg.value << ">\n"
        else
          arg.raise "Include attribute value must be a string literal"
        end
      end
      attr.named_args.try &.each do |named_arg|
        case named_arg.name
        when "flags"
          value = named_arg.value
          case value
          when Crystal::StringLiteral
            flags.concat(value.value.split(' '))
          else
            value.raise "Include flags value must be a string literal"
          end
        else
          named_arg.raise "unknown named argument for Include attribtue"
        end
      end
    end

    {headers.to_s, flags}
  end
end
