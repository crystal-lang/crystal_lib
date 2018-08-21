require "llvm"
require "compiler/crystal/config"

class Clang::Index
  def initialize
    @index = LibClang.create_index(0, 1)
  end

  def parse_translation_unit(source : String, args = [] of String, unsaved_files = [] of UnsavedFile)
    # include default includes directories for builtin headers
    # (see http://clang-developers.42468.n3.nabble.com/Default-header-search-paths-not-included-when-compiling-from-libclang-td4036193.html)
    default_include_directories().each { |dir| args << "-I#{dir}" }
    LibClang.parse_translation_unit2(self, source, args.map &.to_unsafe, args.size,
      unsaved_files.map &.to_unsafe, unsaved_files.size, 1, out tu)
    TranslationUnit.new tu
  end

  def create_translation_unit_from_source_file(source : String, args = [] of String)
    # include default includes directories for builtin headers
    default_include_directories().each { |dir| args << "-I#{dir}" }
    tu = LibClang.create_translation_unit_from_source_file(self, source, args.size, args.map &.to_unsafe, 0, nil)
    TranslationUnit.new tu
  end

  def to_unsafe
    @index
  end

  def finalize
    LibClang.dispose_index(@index)
  end

  def default_include_directories
    program = ENV["CC"]? || "cc"
    args = {"-E", "-", "-v"}

    Process.run(program, args, shell: true, error: io = IO::Memory.new)

    include_dirs = [] of String
    found_include = false

    io.rewind.to_s.each_line do |line|
      if line.starts_with?("#include ")
        found_include = true
      elsif found_include
        line = line.lstrip
        break unless line.starts_with?('.') || line.starts_with?('/')
        include_dirs << line.chomp.gsub(/ \([^)]+\)$/, "")
      end
    end

    include_dirs
  end
end
