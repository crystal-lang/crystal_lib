class Clang::Index
  def initialize
    @index = LibClang.create_index(0, 1)
  end

  def parse_translation_unit(source : String?, args = [] of String, unsaved_files = [] of UnsavedFile)
    tu = LibClang.parse_translation_unit(@index, source, args.map &.cstr, args.length,
      unsaved_files.map &.to_unsafe, unsaved_files.length.to_u32, 0_u32)
    TranslationUnit.new tu
  end

  def create_translation_unit_from_source_file(source : String, args = [] of String)
    tu = LibClang.create_translation_unit_from_source_file(@index, source, args.length, args.map &.cstr, 0_u32, nil)
    TranslationUnit.new tu
  end
end
