class CrystalLib::Parser
  getter nodes

  def self.parse(source)
    parser = Parser.new(source)
    parser.parse
    parser.nodes
  end

  def initialize(@source)
    @nodes = [] of ASTNode
    @cursor_hash_to_node = {} of UInt32 => ASTNode
    @idx = Clang::Index.new
    @tu = @idx.parse_translation_unit "input.c", unsaved_files: [Clang::UnsavedFile.new("input.c", source)]
  end

  def parse
    @tu.cursor.visit_children do |cursor|
      node = visit(cursor)
      @nodes << node if node
      Clang::VisitResult::Continue
    end
  end

  def visit(cursor)
    # puts "#{cursor.kind}: #{cursor.spelling}"

    case cursor.kind
    when Clang::Cursor::Kind::MacroDefinition
      visit_macro_definition(cursor)
    when Clang::Cursor::Kind::VarDecl
      visit_var_declaration(cursor)
    when Clang::Cursor::Kind::FunctionDecl
      visit_function_declaration(cursor)
    when Clang::Cursor::Kind::StructDecl
      visit_struct_or_union_declaration(cursor, :struct)
    when Clang::Cursor::Kind::UnionDecl
      visit_struct_or_union_declaration(cursor, :union)
    when Clang::Cursor::Kind::TypedefDecl
      visit_typedef_declaration(cursor)
    when Clang::Cursor::Kind::EnumDecl
      visit_enum_declaration(cursor)
    end
  end

  def visit_macro_definition(cursor)
    name = name(cursor)
    value = macro_definition_value(cursor)
    Define.new(name, value)
  end

  def macro_definition_value(cursor)
    value = String.build do |str|
      tokens = @tu.tokenize(cursor.extent)
      first = true
      old_line = nil
      tokens.each do |token|
        # Sometimes the tokenizations goes beyond one line (bug in clang?),
        # so we only get the define's value of a single line
        line = token.location.file_location.line
        break if old_line != nil && old_line != line
        old_line = line

        if first
          first = false
          next
        end

        case token.kind
        when Clang::Token::Kind::Literal
          str << token.spelling
        when Clang::Token::Kind::Punctuation
          spelling = token.spelling
          break if spelling == "#"
          str << spelling
        when Clang::Token::Kind::Identifier
          spelling = token.spelling
          str << spelling
        else
          # Nothing
        end
      end
    end
    value.strip
  end

  def visit_var_declaration(cursor)
    name = name(cursor)
    type = type(cursor.type)
    Var.new(name, type)
  end

  def visit_param_declaration(cursor)
    name = name(cursor)
    type = type(cursor.type)
    Arg.new(name, type)
  end

  def visit_typedef_declaration(cursor)
    name = cursor.spelling
    type = type(cursor.typedef_underlying_type)
    named_types[name] = TypedefType.new(name, type)
    Typedef.new(name, type)
  end

  def visit_function_declaration(cursor)
    name = name(cursor)
    return_type = type(cursor.result_type)
    function = Function.new(name, return_type)

    cursor.visit_children do |subcursor|
      if subcursor.kind == Clang::Cursor::Kind::ParmDecl
        function.args << visit_param_declaration(subcursor)
      end

      Clang::VisitResult::Continue
    end

    function
  end

  def visit_struct_or_union_declaration(cursor, kind)
    name = name(cursor)
    struct_or_union = StructOrUnion.new(kind, name)

    @cursor_hash_to_node[cursor.hash] = struct_or_union

    cursor.visit_children do |subcursor|
      if subcursor.kind == Clang::Cursor::Kind::FieldDecl
        struct_or_union.fields << visit_var_declaration(subcursor)
      end

      Clang::VisitResult::Recurse
    end

    struct_or_union
  end

  def visit_enum_declaration(cursor)
    name = name(cursor)

    type = type(cursor.enum_integer_type)
    enum_decl = Enum.new(name, type)

    cursor.visit_children do |subcursor|
      if subcursor.kind == Clang::Cursor::Kind::EnumConstantDecl
        enum_decl.values << visit_enum_constant_declaration(subcursor)
      end

      Clang::VisitResult::Recurse
    end

    enum_decl
  end

  def visit_enum_constant_declaration(cursor)
    EnumValue.new(cursor.spelling, cursor.enum_value)
  end

  def name(cursor)
    name = cursor.spelling
    name = "" if name.empty?
    name
  end

  def type(type)
    case type.kind
    when Clang::Type::Kind::Pointer
      pointee_type = type.pointee_type

      # Check the case of a function pointer type
      result_type = pointee_type.result_type
      if result_type.kind != Clang::Type::Kind::Invalid
        arg_types = Array(Type).new(pointee_type.num_arg_types) { |index| type(pointee_type.arg_type(index)) }
        return function_type(arg_types, type(result_type))
      end

      pointer_type(type(pointee_type))
    when Clang::Type::Kind::ConstantArray
      constant_array_type(type(type.array_element_type), type.array_size)
    when Clang::Type::Kind::Typedef
      spelling = type.spelling.gsub("const ", "")
      named_types[spelling]? || primitive_type(Clang::Type::Kind::Invalid)
    when Clang::Type::Kind::Unexposed
      existing = @cursor_hash_to_node[type.cursor.hash]?
      if existing
        NodeRef.new(existing)
      else
        primitive_type(Clang::Type::Kind::Invalid)
      end
    else
      primitive_type(type.kind)
    end
  end

  def primitive_types
    @primitive_types ||= {} of Clang::Type::Kind => Type
  end

  def pointer_types
    @pointer_types ||= {} of typeof(object_id) => Type
  end

  def named_types
    @named_types ||= {} of String => Type
  end

  record ConstantArrayKey, object_id, size

  def constant_array_types
    @constant_array_types ||= {} of ConstantArrayKey => Type
  end

  record FunctionKey, inputs_ids, output_id

  def function_types
    @function_types ||= {} of FunctionKey => Type
  end

  def primitive_type(kind)
    primitive_types[kind] ||= PrimitiveType.new(PrimitiveType::Kind.new(kind.value))
  end

  def pointer_type(type)
    pointer_types[type.object_id] ||= PointerType.new(type)
  end

  def constant_array_type(type, size)
    constant_array_types[ConstantArrayKey.new(type.object_id, size)] ||= ConstantArrayType.new(type, size)
  end

  def function_type(inputs, output)
    function_types[FunctionKey.new(inputs.map(&.object_id), output.object_id)] ||= FunctionType.new(inputs, output)
  end
end
