class CrystalLib::Parser
  getter nodes

  def self.parse(source, flags = [] of String)
    parser = Parser.new(source, flags)
    parser.parse
    nodes = parser.nodes
    # puts nodes.map(&.to_s).join("\n")
    nodes
  end

  def initialize(@source, flags = [] of String)
    @nodes = [] of ASTNode
    @cursor_hash_to_node = {} of UInt32 => ASTNode
    @idx = Clang::Index.new
    @tu = @idx.parse_translation_unit "input.c", args: flags, unsaved_files: [Clang::UnsavedFile.new("input.c", source)]
  end

  def parse
    @tu.cursor.visit_children do |cursor|
      node = visit(cursor)
      if node
        @nodes << node
        Clang::VisitResult::Continue
      else
        Clang::VisitResult::Recurse
      end
    end
  end

  def visit(cursor)
    case cursor.kind
    when .macro_definition?
      visit_macro_definition(cursor)
    when .var_decl?
      visit_var_declaration(cursor)
    when .function_decl?
      visit_function_declaration(cursor)
    when .struct_decl?
      visit_struct_or_union_declaration(cursor, :struct)
    when .union_decl?
      visit_struct_or_union_declaration(cursor, :union)
    when .typedef_decl?
      visit_typedef_declaration(cursor)
    when .enum_decl?
      visit_enum_declaration(cursor)
    else
      # puts "#{cursor.kind}: #{cursor.spelling}"
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
        when Clang::Token::Kind::Identifier,
             Clang::Token::Kind::Keyword
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
    variadic = cursor.variadic?

    name = name(cursor)
    return_type = type(cursor.result_type)
    function = Function.new(name, return_type, variadic)

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

    @cursor_hash_to_node[cursor.hash] = enum_decl

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

      # Check the case of a function pointer type. I couldn't find another one to do this
      # other than checking the result type, and if it's not invalid it means it's a function
      result_type = pointee_type.result_type
      if result_type.kind != Clang::Type::Kind::Invalid
        return build_function_type(pointee_type, result_type)
      end

      pointer_type(type(pointee_type))
    when Clang::Type::Kind::FunctionProto
      build_function_type type
    when Clang::Type::Kind::BlockPointer
      block_pointer_type(type(type.pointee_type))
    when Clang::Type::Kind::ConstantArray
      constant_array_type(type(type.array_element_type), type.array_size)
    when Clang::Type::Kind::IncompleteArray
      incomplete_array_type(type(type.array_element_type))
    when Clang::Type::Kind::Typedef
      spelling = type.spelling.gsub("const ", "")
      named_types[spelling]? || primitive_type(Clang::Type::Kind::Invalid)
    when Clang::Type::Kind::Unexposed
      existing = @cursor_hash_to_node[type.cursor.hash]?
      if existing
        NodeRef.new(existing)
      else
        UnexposedType.new(type.cursor.spelling)
      end
    when PrimitiveType::Kind::Void,
         PrimitiveType::Kind::Bool,
         PrimitiveType::Kind::Char_S,
         PrimitiveType::Kind::SChar,
         PrimitiveType::Kind::UChar,
         PrimitiveType::Kind::Int,
         PrimitiveType::Kind::Short,
         PrimitiveType::Kind::Long,
         PrimitiveType::Kind::LongLong,
         PrimitiveType::Kind::UInt,
         PrimitiveType::Kind::UShort,
         PrimitiveType::Kind::ULong,
         PrimitiveType::Kind::ULongLong,
         PrimitiveType::Kind::Float,
         PrimitiveType::Kind::Double,
         PrimitiveType::Kind::LongDouble
      primitive_type(type.kind)
    else
      raise "Don't know how to convert #{type.spelling} (#{type.kind})"
    end
  end

  def build_function_type(type, result_type = type.result_type)
    arg_types = Array(Type).new(type.num_arg_types) { |index| type(type.arg_type(index)) }
    function_type(arg_types, type(result_type))
  end

  def primitive_types
    @primitive_types ||= {} of Clang::Type::Kind => Type
  end

  def pointer_types
    @pointer_types ||= {} of typeof(object_id) => Type
  end

  def block_pointer_types
    @block_pointer_types ||= {} of typeof(object_id) => Type
  end

  def named_types
    @named_types ||= {} of String => Type
  end

  record ConstantArrayKey, object_id, size

  def constant_array_types
    @constant_array_types ||= {} of ConstantArrayKey => Type
  end

  def incomplete_array_types
    @incomplete_array_types ||= {} of typeof(object_id) => Type
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

  def block_pointer_type(type)
    block_pointer_types[type.object_id] ||= BlockPointerType.new(type)
  end

  def constant_array_type(type, size)
    constant_array_types[ConstantArrayKey.new(type.object_id, size)] ||= ConstantArrayType.new(type, size)
  end

  def incomplete_array_type(type)
    incomplete_array_types[type.object_id] ||= IncompleteArrayType.new(type)
  end

  def function_type(inputs, output)
    function_types[FunctionKey.new(inputs.map(&.object_id), output.object_id)] ||= FunctionType.new(inputs, output)
  end
end
