struct Clang::Type
  def initialize(@type)
  end

  def spelling
    String.new(LibClang.get_type_spelling(self))
  end

  def canonical_type
    Type.new(LibClang.get_canonical_type(self))
  end

  def kind
    @type.kind
  end

  def to_unsafe
    @type
  end
end
