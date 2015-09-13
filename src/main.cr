require "compiler/crystal/**"
require "./clang"
require "./crystal_lib"

# node = Crystal::Parser.parse %(
#   @[Include("pcre.h")]
#   @[Link("PCRE")]
#   lib LibPCRE
#     INFO_CAPTURECOUNT = PCRE_INFO_CAPTURECOUNT
#     INFO_NAMEENTRYSIZE = PCRE_INFO_NAMEENTRYSIZE
#     fun compile = pcre_compile
#     $pcre_malloc : Void
#     $pcre_free : Void
#   end
#   )

node = Crystal::Parser.parse %(
  @[Include("sqlite3.h")]
  @[Link("sqlite3")]
  lib LibSQLite3
    fun open = sqlite3_open
    fun open = sqlite3_open_v2
    fun errcode = sqlite3_errcode
    fun errmsg = sqlite3_errmsg
    fun prepare_v2 = sqlite3_prepare_v2
    fun step = sqlite3_step
    fun column_count = sqlite3_column_count
    fun column_type = sqlite3_column_type
    fun column_int64 = sqlite3_column_int64
    fun column_double = sqlite3_column_double
    fun column_text = sqlite3_column_text
    fun column_bytes = sqlite3_column_bytes
    fun column_blob = sqlite3_column_blob
    fun bind_int = sqlite3_bind_int
    fun bind_int64 = sqlite3_bind_int64
    fun bind_text = sqlite3_bind_text
    fun bind_blob = sqlite3_bind_text
    fun bind_null = sqlite3_bind_null
    fun bind_double = sqlite3_bind_double

    fun bind_parameter_index = sqlite3_bind_parameter_index
    fun reset = sqlite3_reset
    fun column_name = sqlite3_column_name
    fun last_insert_rowid = sqlite3_last_insert_rowid

    fun finalize = sqlite3_finalize
    fun close_v2 = sqlite3_close_v2
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
