struct Clang::TranslationUnit
  def initialize(@tu)
  end

  def num_diagnostics
    LibClang.get_num_diagnostics(@tu)
  end

  def cursor
    Cursor.new(LibClang.get_translation_unit_cursor(@tu))
  end
end
