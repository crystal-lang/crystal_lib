require "spec"
require "../src/crystal_lib"

include CrystalLib

def parse(source, flags = [] of String, options = Parser::Option::None)
  Parser.parse(source, flags, options)
end
