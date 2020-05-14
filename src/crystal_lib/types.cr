require "clang/type_kind"

module CrystalLib
  abstract class Type
  end

  class PrimitiveType < Type
    alias Kind = Clang::TypeKind

    @kind : Kind
    property kind

    def initialize(@kind : Kind)
    end

    def to_s(io)
      io << kind.spelling
    end

    def_equals_and_hash kind

    def self.int
      new(Clang::TypeKind::Int)
    end

    def self.float
      new(Clang::TypeKind::Float)
    end

    def self.char
      new(Clang::TypeKind::Char_S)
    end

    def self.void
      new(Clang::TypeKind::Void)
    end
  end

  class PointerType < Type
    property type

    def initialize(@type : Type)
    end

    def to_s(io)
      io << @type << "*"
    end

    def_equals_and_hash type
  end

  class BlockPointerType < Type
    property type

    def initialize(@type : Type)
    end

    def to_s(io)
      io << @type << "^"
    end

    def_equals_and_hash type
  end

  class ConstantArrayType < Type
    property type
    property size

    def initialize(@type : Type, @size : Int64)
    end

    def to_s(io)
      io << @type << "[" << @size << "]"
    end

    def_equals_and_hash type, size
  end

  class IncompleteArrayType < Type
    property type

    def initialize(@type : Type)
    end

    def to_s(io)
      io << @type << "[]"
    end

    def_equals_and_hash type
  end

  class FunctionType < Type
    property inputs
    property output

    def initialize(@inputs : Array(Type), @output : Type)
    end

    def to_s(io)
      {% if compare_versions(Crystal::VERSION, "0.35.0-0") >= 0 %}
        @inputs.join(io, ", ")
      {% else %}
        @inputs.join(", ", io)
      {% end %}
      io << " -> " << @output
    end

    def_equals_and_hash inputs, output
  end

  class TypedefType < Type
    property name
    property type

    def initialize(@name : String, @type : Type)
    end

    def to_s(io)
      io << @name
    end

    def_equals_and_hash name, type
  end

  class UnexposedType < Type
    property name

    def initialize(@name : String)
    end

    def to_s(io)
      io << @name
    end

    def_equals_and_hash name
  end

  class ErrorType < Type
    property name

    def initialize(@name : String)
    end

    def to_s(io)
      io << @name
    end

    def_equals_and_hash name
  end

  class NodeRef < Type
    property node

    def initialize(@node : ASTNode)
    end

    def to_s(io)
      node.name.to_s(io)
    end

    def ==(other : self)
      node.name == other.node.name
    end

    def hash
      node.name.hash
    end
  end

  class VaListType < Type
  end
end
