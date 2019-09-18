require "./crystal_lib"

node = Crystal::Parser.parse(ARGF.gets_to_end)
visitor = CrystalLib::LibTransformer.new
transformed = node.transform visitor
transformed.to_s(STDOUT, emit_doc: true)
