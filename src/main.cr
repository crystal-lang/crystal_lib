require "compiler/crystal/**"
require "./clang"
require "./crystal_lib"

include CrystalLib

class LibTransformer < Crystal::Transformer
  getter! nodes

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
    @nodes = CrystalLib::Parser.parse(headers)

    node.body = node.body.transform self
    node
  end

  def transform(node : Crystal::FunDef)
    func = find_function node.real_name
    raise "can't find function #{node.real_name}" unless func

    node.args = func.args.map_with_index do |arg, i|
      arg_type = map_type(arg.type)
      Crystal::Arg.new(arg.name.empty? ? "x#{i}" : arg.name, arg_type)
    end
    node.return_type = map_type(func.return_type)

    check_pending_definitions(node)
  end

  def transform(node : Crystal::Assign)
    name = (node.value as Crystal::Path).names.first
    match = find(name)
    case match
    when Define
      node.value = Crystal::Parser.parse(match.value)
    else
      raise "Unexpected type for constant: #{node}, #{match}, #{match.class}"
    end
    node
  end

  private def map_type(type : PrimitiveType)
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

  private def map_type(type : PointerType)
    Crystal::Generic.new(Crystal::Path.new("Pointer"), map_type(type.type))
  end

  private def map_type(type : TypedefType)
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

  private def map_type(type)
    raise "Unsupported: #{type}, #{type.class}"
  end

  private def declare_alias(name, type)
    @pending_definitions << Crystal::Alias.new(name, type)
  end

  private def check_pending_definitions(node)
    if @pending_definitions.empty?
      node
    else
      nodes = typeof(@pending_definitions).new
      nodes.concat @pending_definitions
      nodes << node

      Crystal::Expressions.new(nodes)
    end
  end

  private def find_function(name)
    match = find(name)
    match.is_a?(Function) ? match : nil
  end

  private def find(name)
    nodes.find { |node| node.name == name }
  end
end

node = Crystal::Parser.parse %(
  @[Include("pcre.h")]
  @[Link("PCRE")]
  lib LibPCRE
    INFO_CAPTURECOUNT = PCRE_INFO_CAPTURECOUNT
    INFO_NAMEENTRYSIZE = PCRE_INFO_NAMEENTRYSIZE
    fun compile = pcre_compile
  end
  )

visitor = LibTransformer.new
transformed = node.transform visitor
puts transformed



# lib_def = node as Crystal::LibDef
# lib_name = lib_def.name

# pp lib_def
# pp lib_name

# SDL
# headers = %w(SDL/SDL.h)
# link_name = "SDL"
# lib_name = "LibSDL"
# prefixes = %w(sdl_ SDL_)

# pcre
# headers = %w(pcre.h)
# link_name = "pcre"
# lib_name = "LibPCRE"
# prefixes = %w(pcre_ PCRE_)

# sqlite3
# headers = %w(sqlite3.h)
# link_name = "sqlite3"
# lib_name = "LibSQLite3"
# prefixes = %w(sqlite3_ SQLITE_)

# LLVM
# headers = %w(llvm-c/Core.h)
# link_name = "llvm"
# lib_name = "LibLLVM"
# prefixes = %w(LLVM)

# source = headers.map { |header| "#include <#{header}>" }.join "\n"

# nodes = CrystalLib::Parser.parse(source)
# puts nodes.join("\n")
# generator = Generator.new link_name, lib_name, prefixes, STDOUT
# generator.process nodes
