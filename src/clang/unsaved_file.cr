struct Clang::UnsavedFile
  def initialize(name, content)
    @unsaved_file = LibClang::UnsavedFile.new
    @unsaved_file.filename = name
    @unsaved_file.contents = content
    @unsaved_file.length = content.size
  end

  def to_unsafe
    @unsaved_file
  end
end
