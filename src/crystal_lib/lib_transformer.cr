class CrystalLib::LibTransformer < Crystal::Transformer
  def initialize
    @includes = [] of Crystal::Attribute
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
    headers, flags, prefixes = process_includes
    nodes = CrystalLib::Parser.parse(headers, flags)

    if prefixes.empty?
      node.body = node.body.transform CrystalLib::LibBodyTransformer.new(nodes)
    else
      node.body = CrystalLib::PrefixImporter.import(nodes, prefixes)
    end

    node
  end

  def process_includes
    headers = MemoryIO.new
    flags = [] of String
    prefixes = [] of String

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
        when "prefix"
          value = named_arg.value
          case value
          when Crystal::StringLiteral
            prefixes << value.value
          when Crystal::ArrayLiteral
            value.elements.each do |value2|
              case value2
              when Crystal::StringLiteral
                prefixes << value2.value
              else
                value.raise "Include prefix value must be a string literal or array literal of string literals"
              end
            end
          else
            value.raise "Include prefix value must be a string literal or array literal"
          end
        else
          named_arg.raise "unknown named argument for Include attribtue"
        end
      end
    end

    {headers.to_s, flags, prefixes}
  end
end
