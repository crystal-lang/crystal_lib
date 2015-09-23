require "./type"

struct Clang::Cursor
  def initialize(@cursor)
  end

  def kind
    LibClang.get_cursor_kind(self)
  end

  def type
    Type.new(LibClang.get_cursor_type(self))
  end

  def typedef_underlying_type
    Type.new(LibClang.get_typedef_decl_underlying_type(self))
  end

  def result_type
    Type.new(LibClang.get_cursor_result_type(self))
  end

  def enum_integer_type
    Type.new(LibClang.get_enum_decl_integer_type(self))
  end

  def enum_value
    LibClang.get_enum_constant_decl_value(self)
  end

  def display_name
    Clang.string(LibClang.get_cursor_display_name(self))
  end

  def spelling
    Clang.string(LibClang.get_cursor_spelling(self))
  end

  def location
    SourceLocation.new(LibClang.get_cursor_location(self))
  end

  def extent
    SourceRange.new(LibClang.get_cursor_extent(self))
  end

  def visit_children(&block : Cursor -> Clang::VisitResult)
    LibClang.visit_children(@cursor, ->(cursor, parent, data) {
      proc = Box(typeof(block)).unbox(data)
      proc.call(Cursor.new(cursor))
    }, Box.box(block))
  end

  def declaration?
    LibClang.is_declaration(kind) != 0
  end

  def reference?
    LibClang.is_reference(kind) != 0
  end

  def expression?
    LibClang.is_expression(kind) != 0
  end

  def statement?
    LibClang.is_statement(kind) != 0
  end

  def attribute?
    LibClang.is_attribute(kind) != 0
  end

  def invalid?
    LibClang.is_invalid(kind) != 0
  end

  def translation_unit?
    LibClang.is_translation_unit(kind) != 0
  end

  def preprocessing?
    LibClang.is_preprocessing(kind) != 0
  end

  def unexposed?
    LibClang.is_unexposed(kind) != 0
  end

  def variadic?
    LibClang.cursor_is_variadic(self) != 0
  end

  def hash
    LibClang.hash_cursor(self)
  end

  def to_unsafe
    @cursor
  end
end
