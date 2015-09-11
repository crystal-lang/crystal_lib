class CrystalLib::Generator
  def initialize(@link, @lib_name, @prefixes, @io)
    @defines = Set(String).new
  end

  def process(nodes)
    @io << %{@[Link("} << @link << %{")]\n}
    @io << "lib " << @lib_name << "\n"
    nodes.each do |node|
      visit node
    end
    @io << "end\n"
  end

  def visit(node : Define)
    name = nil
    @prefixes.each do |prefix|
      if node.name.starts_with?(prefix)
        name = node.name[prefix.length .. -1]
        break
      end
    end
    return unless name

    value = node.value
    @prefixes.each do |prefix|
      value = value.gsub(prefix, "")
    end
    value = value.strip

    return if node.name == node.value
    return unless 'A' <= name[0] <= 'Z'

    # Skip some values which are invalid crystal values
    return if value.ends_with?('*')
    return if value.match(/\(\S+\)\S/)
    return if value.match(/\w\(\S+\)/)
    return if value.match(/".+"./)
    return if value.match(/.".+"/)

    value = value[1 ... -1] if value =~ /\A\(.+\)\Z/

    if value =~ /\A[a-zA-Z_]+\Z/
      return unless @defines.includes?(value)
    end

    @io << "  " << name << " = " << value << "\n"
    @defines << name
  end

  def visit(node : StructOrUnion)
    name = nil
    @prefixes.each do |prefix|
      if node.name.starts_with?(prefix)
        name = node.name[prefix.length .. -1]
        break
      end
    end
    return unless name

    @io << "  " << node.kind << " " << name << "\n"
    @io << "  end\n"
  end

  def visit(node)
  end
end
