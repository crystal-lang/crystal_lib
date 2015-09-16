struct Clang::Index
  def initialize
    @index = LibClang.create_index(0, 1)
  end

  def parse_translation_unit(source : String, args = [] of String, unsaved_files = [] of UnsavedFile)
    LibClang.parse_translation_unit2(@index, source, args.map &.to_unsafe, args.size,
      unsaved_files.map &.to_unsafe, unsaved_files.size.to_u32, 1_u32, out tu)
    TranslationUnit.new tu
  end

  def create_translation_unit_from_source_file(source : String, args = [] of String)
    tu = LibClang.create_translation_unit_from_source_file(@index, source, args.size, args.map &.cstr, 0_u32, nil)
    TranslationUnit.new tu
  end
end
