require "spec"
require "../src/crystal_lib"
require "../src/clang"

include CrystalLib

def parse(source)
  Parser.parse(source)
end
