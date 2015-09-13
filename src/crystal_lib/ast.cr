module CrystalLib
  abstract class ASTNode
  end

  class Define < ASTNode
    property name
    property value

    def initialize(@name, @value)
    end

    def to_s(io, semicolon = true)
      io << "#define " << @name << " " << @value
    end

    def_equals_and_hash name, value
  end

  class Var < ASTNode
    property name
    property type

    def initialize(@name, @type)
    end

    def to_s(io, semicolon = true)
      io << @type << " " << @name
      io << ";" if semicolon
    end

    def_equals_and_hash name, type
  end

  class Function < ASTNode
    property name
    property args
    property return_type

    def initialize(@name, @return_type)
      @args = [] of Arg
    end

    def to_s(io, semicolon = true)
      io << @return_type << " " << @name
      io << "("
      @args.join(", ", io)
      io << ")"
      io << ";" if semicolon
    end

    def_equals_and_hash name, args, return_type
  end

  class Arg < ASTNode
    property name
    property type

    def initialize(@name, @type)
    end

    def to_s(io, semicolon = true)
      io << @type
      io << " " << @name if @name
    end

    def_equals_and_hash name, type
  end

  class StructOrUnion < ASTNode
    property kind
    property name
    property fields

    def initialize(@kind, name)
      if name.empty?
        @name = ""
      else
        @name = "#{@kind} #{name}"
      end
      @fields = [] of Var
    end

    def to_s(io, semicolon = true)
      if name.empty?
        io << @kind
      else
        io << name
      end
      io << " {\n"
      @fields.each do |field|
        io << "  " << field.type << " " << field.name << ";\n"
      end
      io << "}"
      io << ";" if semicolon
    end

    def_equals_and_hash kind, name, fields
  end

  class Typedef < ASTNode
    property name
    property type

    def initialize(@name, @type)
    end

    def to_s(io, semicolon = true)
      io << "typedef " << @type << " " << @name
      io << ";" if semicolon
    end

    def_equals_and_hash name, type
  end

  class Enum < ASTNode
    property name
    property type
    property values

    def initialize(@name, @type)
      @values = [] of EnumValue
    end

    def to_s(io, semicolon = true)
      io << "enum"
      io << " " << @name if @name
      io << " {"
      @values.each_with_index do |value, i|
        if i > 0
          io << ",\n"
        else
          io << "\n"
        end
        io << "  " << value
      end
      io << "\n}"
      io << ";" if semicolon
    end

    def_equals_and_hash name, type, values
  end

  class EnumValue < ASTNode
    property name
    property value

    def initialize(@name, @value)
    end

    def to_s(io, semicolon = true)
      io << @name << " = " << @value
    end

    def_equals_and_hash name, value
  end
end


