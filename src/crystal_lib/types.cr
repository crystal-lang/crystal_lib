require "../clang/enums"

module CrystalLib
  abstract class Type
  end

  class PrimitiveType < Type
    enum Kind
      Invalid = Clang::Type::Kind::Invalid
      Void = Clang::Type::Kind::Void
      Bool = Clang::Type::Kind::Bool
      Char_U = Clang::Type::Kind::Char_U
      UChar = Clang::Type::Kind::UChar
      Char16 = Clang::Type::Kind::Char16
      Char32 = Clang::Type::Kind::Char32
      UShort = Clang::Type::Kind::UShort
      UInt = Clang::Type::Kind::UInt
      ULong = Clang::Type::Kind::ULong
      ULongLong = Clang::Type::Kind::ULongLong
      UInt128 = Clang::Type::Kind::UInt128
      Char_S = Clang::Type::Kind::Char_S
      SChar = Clang::Type::Kind::SChar
      WChar = Clang::Type::Kind::WChar
      Short = Clang::Type::Kind::Short
      Int = Clang::Type::Kind::Int
      Long = Clang::Type::Kind::Long
      LongLong = Clang::Type::Kind::LongLong
      Int128 = Clang::Type::Kind::Int128
      Float = Clang::Type::Kind::Float
      Double = Clang::Type::Kind::Double
      LongDouble = Clang::Type::Kind::LongDouble
      NullPtr = Clang::Type::Kind::NullPtr
    end

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
