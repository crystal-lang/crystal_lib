class Clang::Tokenization
  include Enumerable(Token)

  def initialize(@translation_unit, @tokens)
  end

  def each
    @tokens.each do |token|
      yield wrap(token)
    end
  end

  def length
    @tokens.size
  end

  def [](index)
    wrap @tokens[index]
  end

  def to_s(io)
    @tokens.each do |token|
      wrap(token).kind.to_s(io)
    end
  end

  def translation_unit
    @translation_unit
  end

  def finalize
    LibClang.dispose_tokens(@translation_unit, @tokens, @tokens.size)
  end

  private def wrap(token)
    Token.new(self, token)
  end
end
