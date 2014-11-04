struct Clang::SourceLocation
  def initialize(@location)
  end

  def is_from_main_file?
    LibClang.location_is_from_main_file(self) != 0
  end

  def to_unsafe
    @location
  end
end
