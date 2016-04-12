struct Clang::SourceLocation
  def initialize(@location : LibClang::SourceLocation)
  end

  def is_from_main_file?
    LibClang.location_is_from_main_file(self) != 0
  end

  def file_location
    LibClang.get_file_location(self, out file, out line, out column, out offset)
    filename = file ? Clang.string(LibClang.get_file_name(file)) : nil
    FileLocation.new filename, line, column, offset
  end

  def to_unsafe
    @location
  end
end
