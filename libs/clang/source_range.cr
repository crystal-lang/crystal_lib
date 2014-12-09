struct Clang::SourceRange
  def initialize(@range)
  end

  def start
    SourceLocation.new(LibClang.get_range_start(self))
  end

  def end
    SourceLocation.new(LibClang.get_range_end(self))
  end

  def to_unsafe
    @range
  end
end
