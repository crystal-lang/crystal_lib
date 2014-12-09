require "clang"
require "json"

abstract class LibElementSpec
end

class ConstantsSpec < LibElementSpec
  def initialize(json : Json::PullParser)
    @remove_prefix = false
    prefix = nil

    json.read_object do |key|
      case key
      when "prefix"
        prefix = json.read_string
      when "remove_prefix"
        @remove_prefix = json.read_bool
      end
    end

    @prefix = prefix.not_nil!
  end

  def handle_cursor(tu, cursor)
    return false unless cursor.kind == Clang::Cursor::Kind::MacroDefinition
    return false unless cursor.spelling.starts_with? @prefix

    if @remove_prefix
      name = cursor.spelling[@prefix.length .. -1]
    else
      name = cursor.spelling
    end

    tokens = tu.tokenize(cursor.extent)
    value = String.build do |str|
      tokens.each do |token|
        case token.kind
        when Clang::Token::Kind::Literal
          str << token.spelling
        when Clang::Token::Kind::Punctuation
          spelling = token.spelling
          break if spelling == "#"
          str << spelling
        end
      end
    end

    puts "#{name} #{value}"
    true
  end
end

class LibSpec
  property! input
  property libname
  property! imports

  def initialize(json : Json::PullParser)
    json.read_object do |key|
      case key
      when "input"
        @input = Array(String).new(json)
      when "libname"
        @libname = String.new(json)
      when "import"
        @imports = imports = [] of LibElementSpec
        json.read_object do |elem_key|
          case elem_key
          when "constants"
            imports << ConstantsSpec.new(json)
          end
        end
      end
    end
  end

  def handle_cursor(tu, cursor)
    imports.each &.handle_cursor(tu, cursor)
  end
end

filename = ARGV[0]?
unless filename
  puts "usage: crystal_lib lib_spec"
  exit
end

unless File.exists?(filename) && !Dir.exists?(filename)
  puts "File '#{filename}' is not a file or it does not exist"
  exit
end

lib_spec = LibSpec.from_json(File.read(filename))

input_file_contents = lib_spec.input.map {|hdr| %(#include <#{hdr}>)}.join "\n"

idx = Clang::Index.new
tu = idx.parse_translation_unit "input.c", [] of String, [Clang::UnsavedFile.new("input.c", input_file_contents)]

tu.cursor.visit_children do |cursor|
  lib_spec.handle_cursor(tu, cursor)
  Clang::VisitResult::Recurse
end
