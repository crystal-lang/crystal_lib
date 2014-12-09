struct Clang::SourceLocation
  def initialize(@location)
  end

  def is_from_main_file?
    LibClang.location_is_from_main_file(self) != 0
  end

  def file_location
    LibClang.get_file_location(self, out file, out line, out column, out offset)
    if file
      {String.new(LibClang.get_file_name(file)), line, column, offset}
    else
      {nil, line, column, offset}
    end
  end

  def to_unsafe
    @location
  end
end
