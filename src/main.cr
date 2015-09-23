require "./clang"
require "./crystal_lib"

node = Crystal::Parser.parse(ARGF.read)
visitor = CrystalLib::LibTransformer.new
transformed = node.transform visitor
puts transformed
