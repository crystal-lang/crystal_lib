require "spec"
require "../src/crystal_lib"

include CrystalLib

def parse(source)
  Parser.parse(source)
end
