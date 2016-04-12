struct Clang::Type
  def initialize(@type : LibClang::Type)
  end

  def spelling
    Clang.string(LibClang.get_type_spelling(self))
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

  def result_type
    Type.new LibClang.get_result_type(self)
  end

  def num_arg_types
    LibClang.get_num_arg_types(self)
  end

  def arg_types
    Array.new(num_arg_types) { |i| arg_type(i) }
  end

  def arg_type(index)
    Type.new LibClang.get_arg_type(self, index.to_u32)
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
