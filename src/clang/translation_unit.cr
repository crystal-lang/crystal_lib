class Clang::TranslationUnit
  def initialize(@tu : LibClang::TranslationUnit)
  end

  def num_diagnostics
    LibClang.get_num_diagnostics(self)
  end

  def cursor
    Cursor.new(LibClang.get_translation_unit_cursor(self))
  end

  def tokenize(source_range)
    LibClang.tokenize(self, source_range, out tokens, out num_tokens)
    Tokenization.new self, Slice.new(tokens, num_tokens.to_i)
  end

  def to_unsafe
    @tu
  end

  def finalize
    LibClang.dispose_translation_unit(@tu)
  end
end
