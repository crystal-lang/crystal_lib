class Clang::Tokenization
  include Enumerable(Token)

  def initialize(@translation_unit, @native_tokens)
    @tokens = @native_tokens.map { |t| Token.new(self, t) }
  end

  def each
    @tokens.each { |x| yield x }
  end

  def length
    @tokens.size
  end

  def [](index)
    @tokens[index]
  end

  def to_s(io)
    @tokens.map(&.kind).to_s(io)
  end

  def translation_unit
    @translation_unit
  end
end
