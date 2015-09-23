class Clang::Index
  def initialize
    @index = LibClang.create_index(0, 1)
  end

  def parse_translation_unit(source : String, args = [] of String, unsaved_files = [] of UnsavedFile)
    LibClang.parse_translation_unit2(self, source, args.map &.to_unsafe, args.size,
      unsaved_files.map &.to_unsafe, unsaved_files.size, 1, out tu)
    TranslationUnit.new tu
  end

  def create_translation_unit_from_source_file(source : String, args = [] of String)
    tu = LibClang.create_translation_unit_from_source_file(self, source, args.size, args.map &.cstr, 0, nil)
    TranslationUnit.new tu
  end

  def to_unsafe
    @index
  end

  def finalize
    LibClang.dispose_index(@index)
  end
end
