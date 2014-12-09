struct Clang::Token
  def initialize(@tokenization, @token)
  end

  def to_unsafe
    @token
  end

  def kind
    LibClang.get_token_kind(self)
  end

  def spelling
    String.new LibClang.get_token_spelling(@tokenization.translation_unit, self)
  end
end
