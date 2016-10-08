require "./enums"

@[Link("clang")]
{% if flag?(:darwin) %}
  @[Link(ldflags: "-L`xcode-select --print-path`/usr/lib")]
  @[Link(ldflags: "-rpath `xcode-select --print-path`/usr/lib")]
{% else %}
  @[Link(ldflags: "`llvm-config-3.6 --ldflags 2>/dev/null || llvm-config-3.5 --ldflags 2>/dev/null || llvm-config --ldflags 2>/dev/null`")]
{% end %}
lib LibClang
  type Index = Void*
  type TranslationUnit = Void*
  type File = Void*

  struct Cursor
    kind : Clang::Cursor::Kind
    xdata : Int32
    data : Pointer(Void)[3]
  end

  struct Type
    kind : Clang::Type::Kind
    data : Pointer(Void)[2]
  end

  type CursorVisitor = (Cursor, Cursor, Void*) -> Clang::VisitResult

  struct UnsavedFile
    filename : UInt8*
    contents : UInt8*
    length : UInt64
  end

  struct SourceLocation
    ptr_data : Pointer(Void)[2]
    int_data : UInt32
  end

  struct SourceRange
    ptr_data : Pointer(Void)[2]
    begin_int_data : UInt32
    end_int_data : UInt32
  end

  struct Token
    int_data : UInt32[4]
    ptr_data : Void*
  end

  alias CursorKind = Clang::Cursor::Kind

  struct String
    data : Void*
    private_flags : UInt32
  end

  fun create_index = clang_createIndex(excludeDeclarationsFromPCH : Int32, displayDiagnostics : Int32) : Index
  fun parse_translation_unit2 = clang_parseTranslationUnit2(idx : Index,
                                                            source_filename : UInt8*,
                                                            command_line_args : UInt8**,
                                                            num_command_line_args : Int32,
                                                            unsaved_files : UnsavedFile*,
                                                            num_unsaved_files : UInt32,
                                                            options : UInt32,
                                                            tu : TranslationUnit*) : Int32
  fun create_translation_unit_from_source_file = clang_createTranslationUnitFromSourceFile(
                                                                                           Index,
                                                                                           source_filename : UInt8*,
                                                                                           num_clang_command_line_args : Int32,
                                                                                           clang_command_line_args : UInt8**,
                                                                                           num_unsaved_files : UInt32,
                                                                                           unsaved_files : UnsavedFile*) : TranslationUnit

  fun get_translation_unit_cursor = clang_getTranslationUnitCursor(TranslationUnit) : Cursor
  fun visit_children = clang_visitChildren(Cursor, CursorVisitor, client_data : Void*) : UInt32
  fun get_num_diagnostics = clang_getNumDiagnostics(TranslationUnit) : UInt32
  fun get_cursor_kind = clang_getCursorKind(Cursor) : CursorKind
  fun get_cursor_type = clang_getCursorType(Cursor) : Type
  fun get_type_spelling = clang_getTypeSpelling(Type) : String

  fun is_declaration = clang_isDeclaration(CursorKind) : UInt32
  fun is_reference = clang_isReference(CursorKind) : UInt32
  fun is_expression = clang_isExpression(CursorKind) : UInt32
  fun is_statement = clang_isStatement(CursorKind) : UInt32
  fun is_attribute = clang_isAttribute(CursorKind) : UInt32
  fun is_invalid = clang_isInvalid(CursorKind) : UInt32
  fun is_translation_unit = clang_isTranslationUnit(CursorKind) : UInt32
  fun is_preprocessing = clang_isPreprocessing(CursorKind) : UInt32
  fun is_unexposed = clang_isUnexposed(CursorKind) : UInt32

  fun get_canonical_type = clang_getCanonicalType(Type) : Type
  fun get_cursor_spelling = clang_getCursorSpelling(Cursor) : String
  fun get_cursor_display_name = clang_getCursorDisplayName(Cursor) : String
  fun get_cursor_location = clang_getCursorLocation(Cursor) : SourceLocation
  fun get_cursor_result_type = clang_getCursorResultType(Cursor) : Type
  fun location_is_from_main_file = clang_Location_isFromMainFile(SourceLocation) : Int32
  fun get_cursor_extent = clang_getCursorExtent(Cursor) : SourceRange

  fun get_range_start = clang_getRangeStart(SourceRange) : SourceLocation
  fun get_range_end = clang_getRangeEnd(SourceRange) : SourceLocation

  fun get_file_location = clang_getFileLocation(location : SourceLocation,
                                                file : File*,
                                                line : UInt32*,
                                                column : UInt32*,
                                                offset : UInt32*)
  fun get_file_name = clang_getFileName(file : File) : String

  fun tokenize = clang_tokenize(TranslationUnit, SourceRange, Token**, UInt32*)
  fun get_token_kind = clang_getTokenKind(Token) : Clang::Token::Kind
  fun get_token_spelling = clang_getTokenSpelling(TranslationUnit, Token) : String
  fun get_typedef_decl_underlying_type = clang_getTypedefDeclUnderlyingType(Cursor) : Type
  fun get_enum_decl_integer_type = clang_getEnumDeclIntegerType(Cursor) : Type
  fun get_enum_constant_decl_value = clang_getEnumConstantDeclValue(Cursor) : Int64
  fun get_pointee_type = clang_getPointeeType(Type) : Type
  fun get_result_type = clang_getResultType(Type) : Type
  fun get_array_element_type = clang_getArrayElementType(Type) : Type
  fun get_array_size = clang_getArraySize(Type) : LibC::LongLong
  fun get_token_location = clang_getTokenLocation(TranslationUnit, Token) : SourceLocation
  fun get_type_declaration = clang_getTypeDeclaration(Type) : Cursor
  fun get_num_arg_types = clang_getNumArgTypes(Type) : Int32
  fun get_arg_type = clang_getArgType(Type, UInt32) : Type
  fun cursor_is_variadic = clang_Cursor_isVariadic(Cursor) : UInt32
  fun hash_cursor = clang_hashCursor(Cursor) : UInt32
  fun get_cursor_definition = clang_getCursorDefinition(Cursor) : Cursor

  fun get_cstring = clang_getCString(String) : LibC::Char*

  fun dispose_index = clang_disposeIndex(Index)
  fun dispose_translation_unit = clang_disposeTranslationUnit(TranslationUnit)
  fun dispose_string = clang_disposeString(String)
  fun dispose_tokens = clang_disposeTokens(tu : TranslationUnit, tokens : Token*, num_tokens : UInt32)
end
