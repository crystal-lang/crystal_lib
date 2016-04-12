struct Clang::Token
  def initialize(@tokenization : Tokenization, @token : LibClang::Token)
  end

  def to_unsafe
    @token
  end

  def kind
    LibClang.get_token_kind(self)
  end

  def spelling
    Clang.string(LibClang.get_token_spelling(@tokenization.translation_unit, self))
  end

  def location
    SourceLocation.new LibClang.get_token_location(@tokenization.translation_unit, self)
  end
end
