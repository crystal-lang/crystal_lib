class CrystalLib::PrefixImporter
  def self.import(nodes, prefixes)
    importer = new prefixes
    nodes.each do |node|
      importer.process node
    end
    importer.result
  end

  def initialize(@prefixes)
    @nodes = [] of Crystal::ASTNode
    @mapper = TypeMapper.new(@prefixes)
  end

  def process(node : Define)
    name = match_prefix(node)
    return unless name

    begin
      value = Crystal::Parser.parse(node.value)
      return unless value.is_a?(Crystal::NumberLiteral)
    rescue
      # Ignore for now
      return
    end

    name = Crystal::Path.new(name.upcase)
    @nodes << Crystal::Assign.new(name, value)
  end

  def process(node : Var)
    name = match_prefix(node)
    return unless name

    @nodes << Crystal::ExternalVar.new(name, @mapper.map(node.type))

    check_pending_definitions
  end

  def process(node : Function)
    name = match_prefix(node)
    return unless name

    name = @mapper.crystal_fun_name(name)
    args = node.args.map_with_index do |arg, i|
      Crystal::Arg.new(arg.name.empty? ? "x#{i}" : @mapper.crystal_arg_name(arg.name), restriction: map_type(arg.type))
    end
    return_type = map_type(node.return_type)
    return_type = nil if void?(return_type)

    varargs = node.variadic?

    @nodes << Crystal::FunDef.new(name, args, return_type, varargs, real_name: node.name)

    check_pending_definitions
  end

  def process(node : Enum)
    if node.name.empty?
      node.values.each do |value|
        name = match_prefix(value)
        next unless name

        @nodes << Crystal::Assign.new(Crystal::Path.new(@mapper.crystal_type_name(name)), Crystal::NumberLiteral.new(value.value))
      end
    end
  end

  def process(node : StructOrUnion)
    name = match_prefix(node.unscoped_name)
    return unless name

    @mapper.map(node)

    check_pending_definitions
  end

  def process(node : Typedef)
    # We skip these because they should be imported when importing functions
  end

  def process(node)
    # Nothing to do
  end

  def check_pending_definitions
    return if @mapper.pending_definitions.empty?

    @nodes.concat @mapper.pending_definitions.dup
    @mapper.pending_definitions.clear
  end

  def match_prefix(node : CrystalLib::ASTNode)
    match_prefix(node.name)
  end

  def match_prefix(name : String)
    @prefixes.each do |prefix|
      if name.starts_with?(prefix)
        return name[prefix.size..-1]
      end
    end
    nil
  end

  def map_type(type)
    @mapper.map(type)
  end

  def void?(node)
    node.is_a?(Crystal::Path) && node.names.size == 1 && node.names.first == "Void"
  end

  def result
    @nodes.sort! do |n1, n2|
      compare(n1, n2)
    end

    Crystal::Expressions.from(@nodes)
  end

  def compare(n1 : Crystal::FunDef, n2 : Crystal::FunDef)
    n1.name <=> n2.name
  end

  def compare(n1 : Crystal::StructOrUnionDef, n2 : Crystal::StructOrUnionDef)
    n1.name <=> n2.name
  end

  def compare(n1 : Crystal::ExternalVar, n2 : Crystal::ExternalVar)
    n1.name <=> n2.name
  end

  def compare(n1 : Crystal::EnumDef, n2 : Crystal::EnumDef)
    n1.name.names.first <=> n2.name.names.first
  end

  def compare(n1 : Crystal::Assign, n2 : Crystal::Assign)
    compare(n1.target, n2.target)
  end

  def compare(n1 : Crystal::Path, n2 : Crystal::Path)
    n1.names.first <=> n2.names.first
  end

  def compare(n1 : Crystal::TypeDef, n2 : Crystal::TypeDef)
    n1.name <=> n2.name
  end

  def compare(n1 : Crystal::Alias, n2 : Crystal::Alias)
    n1.name <=> n2.name
  end

  def compare(n1, n2)
    if n1.class == n2.class
      raise "Bug: shoudln't compare #{n1.class} vs. #{n2.class}"
    else
      category(n1) <=> category(n2)
    end
  end

  def category(node)
    case node
    when Crystal::Assign
      0
    when Crystal::EnumDef
      1
    when Crystal::TypeDef
      2
    when Crystal::Alias
      3
    when Crystal::StructOrUnionDef
      4
    when Crystal::FunDef
      5
    when Crystal::ExternalVar
      6
    else
      7
    end
  end
end
