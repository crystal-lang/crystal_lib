require "../clang/enums"

module CrystalLib
  abstract class Type
  end

  class PrimitiveType < Type
    alias Kind = Clang::Type::Kind

    property kind

    def initialize(@kind : Kind)
    end

    def to_s(io)
      io << case kind
            when Kind::Invalid    then "ERROR"
            when Kind::Void       then "void"
            when Kind::Bool       then "bool"
            when Kind::Char_U     then "char_u"
            when Kind::UChar      then "uchar"
            when Kind::Char16     then "char16"
            when Kind::Char32     then "char32"
            when Kind::UShort     then "ushort"
            when Kind::UInt       then "uint"
            when Kind::ULong      then "ulong"
            when Kind::ULongLong  then "ulong long"
            when Kind::UInt128    then "uint128"
            when Kind::Char_S     then "char_s"
            when Kind::SChar      then "schar"
            when Kind::WChar      then "wchar"
            when Kind::Short      then "short"
            when Kind::Int        then "int"
            when Kind::Long       then "long"
            when Kind::LongLong   then "long long"
            when Kind::Int128     then "int128"
            when Kind::Float      then "float"
            when Kind::Double     then "double"
            when Kind::LongDouble then "long double"
            when Kind::NullPtr    then "void*"
            end
    end

    def_equals_and_hash kind

    def self.int
      new(Kind::Int)
    end

    def self.float
      new(Kind::Float)
    end

    def self.char
      new(Kind::Char_S)
    end
  end

  class PointerType < Type
    property type

    def initialize(@type)
    end

    def to_s(io)
      io << @type << "*"
    end

    def_equals_and_hash type
  end

  class ConstantArrayType < Type
    property type
    property size

    def initialize(@type, @size)
    end

    def to_s(io)
      io << @type << "[" << @size << "]"
    end

    def_equals_and_hash type, size
  end

  class FunctionType < Type
    property inputs
    property output

    def initialize(@inputs, @output)
    end

    def to_s(io)
      @inputs.join(", ", io)
      io << " -> " << @output
    end

    def_equals_and_hash inputs, output
  end

  class TypedefType < Type
    property name
    property type

    def initialize(@name, @type)
    end

    def to_s(io)
      io << @name
    end

    def_equals_and_hash name, type
  end

  class NodeRef < Type
    property node

    def initialize(@node)
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
end
