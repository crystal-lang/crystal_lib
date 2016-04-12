require "../clang/enums"

module CrystalLib
  abstract class Type
  end

  class PrimitiveType < Type
    enum Kind
      # Represents an invalid type (e.g., where no type is available).
      Invalid = 0
      # A type whose specific kind is not exposed via this interface.
      Unexposed           =  1
      Void                =  2
      Bool                =  3
      Char_U              =  4
      UChar               =  5
      Char16              =  6
      Char32              =  7
      UShort              =  8
      UInt                =  9
      ULong               = 10
      ULongLong           = 11
      UInt128             = 12
      Char_S              = 13
      SChar               = 14
      WChar               = 15
      Short               = 16
      Int                 = 17
      Long                = 18
      LongLong            = 19
      Int128              = 20
      Float               = 21
      Double              = 22
      LongDouble          = 23
      NullPtr             = 24
      Overload            = 25
      Dependent           = 26
      ObjCId              = 27
      ObjCClass           = 28
      ObjCSel             = 29
      FirstBuiltin        = Void
      LastBuiltin         = ObjCSel
      Complex             = 100
      Pointer             = 101
      BlockPointer        = 102
      LValueReference     = 103
      RValueReference     = 104
      Record              = 105
      Enum                = 106
      Typedef             = 107
      ObjCInterface       = 108
      ObjCObjectPointer   = 109
      FunctionNoProto     = 110
      FunctionProto       = 111
      ConstantArray       = 112
      Vector              = 113
      IncompleteArray     = 114
      VariableArray       = 115
      DependentSizedArray = 116
      MemberPointer       = 117
      VaList              = 999
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

    def self.int
      new(Kind::Int)
    end

    def self.float
      new(Kind::Float)
    end

    def self.char
      new(Kind::Char_S)
    end

    def self.void
      new(Kind::Void)
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

    def initialize(@type : Type, @size : Int32)
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
      @inputs.join(", ", io)
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
end
