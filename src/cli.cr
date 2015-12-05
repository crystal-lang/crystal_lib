require "./clang"
require "./crystal_lib"
require "option_parser"
output_file = ""
OptionParser.parse! do |parser|
  parser.banner = "Usage: crystal_lib [arguments]"
  parser.on("-o FILE", "--output=FILE", "Upcases the sallute") { |filename| output_file = filename }
  parser.on("-h", "--help", "Show this help") { puts parser }
end

if output_file = ""
  output_file = "output.cr"
end

node = Crystal::Parser.parse(ARGF.gets_to_end)
visitor = CrystalLib::LibTransformer.new
transformed = node.transform visitor
File.write(output_file, transformed)
