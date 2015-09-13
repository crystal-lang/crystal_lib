require "compiler/crystal/**"
require "./clang"
require "./crystal_lib"

node = Crystal::Parser.parse %(
  @[Include("pcre.h")]
  @[Link("PCRE")]
  lib LibPCRE
    INFO_CAPTURECOUNT = PCRE_INFO_CAPTURECOUNT
    INFO_NAMEENTRYSIZE = PCRE_INFO_NAMEENTRYSIZE
    fun compile = pcre_compile
  end
  )

visitor = CrystalLib::LibTransformer.new
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
