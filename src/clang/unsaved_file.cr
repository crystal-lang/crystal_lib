struct Clang::UnsavedFile
  def initialize(name, content)
    @unsaved_file = LibClang::UnsavedFile.new
    @unsaved_file.filename = name.cstr
    @unsaved_file.contents = content.cstr
    @unsaved_file.length = content.size.to_u64
  end

  def to_unsafe
    @unsaved_file
  end
end
