require "clang"
require "json"

class LibElementSpec
end

class ConstantsSpec < LibElementSpec
  def initialize(json : Json::PullParser)
    json.read_object do |key|
      case key
      when "prefix"
        @prefix = json.read_string
      when "remove_prefix"
        @remove_prefix = json.read_bool
      end
    end
  end
end

class LibSpec
  property! input
  property libname

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
end


lib_spec = LibSpec.from_json(File.read(ARGV[0]))
puts lib_spec


input_file_contents = lib_spec.input.map {|hdr| %(#include <#{hdr}>)}.join "\n"

idx = Clang::Index.new
tu = idx.parse_translation_unit "input.c", [] of String, [Clang::UnsavedFile.new("input.c", input_file_contents)]

tu.cursor.visit_children do |cursor|
  puts "#{cursor.declaration?} #{cursor.spelling} #{cursor.kind} #{cursor.type.spelling}" #{cursor.type.canonical_type.spelling} #{cursor.type.kind} #{cursor.type.canonical_type.kind}"
  # puts cursor.location.is_from_main_file?
  :continue
end


