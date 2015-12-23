struct Clang::UnsavedFile
  def initialize(name, content)
    @unsaved_file = LibClang::UnsavedFile.new
    @unsaved_file.filename = name.to_unsafe
    @unsaved_file.contents = content.to_unsafe
    @unsaved_file.length = content.size.to_u64
  end

  def to_unsafe
    @unsaved_file
  end
end
