struct Clang::Type
  def initialize(@type)
  end

  def spelling
    String.new(LibClang.get_type_spelling(self))
  end

  def canonical_type
    Type.new(LibClang.get_canonical_type(self))
  end

  def pointee_type
    Type.new(LibClang.get_pointee_type(self))
  end

  def array_element_type
    Type.new(LibClang.get_array_element_type(self))
  end

  def array_size
    LibClang.get_array_size(self).to_i
  end

  def cursor
    Cursor.new(LibClang.get_type_declaration(self))
  end

  def kind
    @type.kind
  end

  def to_unsafe
    @type
  end
end
