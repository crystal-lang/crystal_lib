require "./clang/*"

module Clang
  def self.string(clang_string)
    cstring = LibClang.get_cstring(clang_string)
    String.new(cstring).tap { LibClang.dispose_string(clang_string) }
  end
end
