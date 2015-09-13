require "./spec_helper"

describe Parser do
  it "parses define" do
    nodes = parse("#define FOO 1")
    define = nodes.last as Define
    define.name.should eq("FOO")
    define.value.should eq("1")
  end

  it "parses define with operator" do
    nodes = parse("#define FOO 1 << 2")
    define = nodes.last as Define
    define.name.should eq("FOO")
    define.value.should eq("1<<2")
  end

  it "parses define where a macro call follows" do
    nodes = parse("#define BAR extern\n#define FOO 1\nBAR int x;")
    define = nodes[-2] as Define
    define.name.should eq("FOO")
    define.value.should eq("1")
  end

  it "parses variable" do
    nodes = parse("int some_var;")
    var = nodes.last as Var
    var.name.should eq("some_var")
    var.type.should eq(PrimitiveType.new(PrimitiveType::Kind::Int))
  end

  it "parses function" do
    nodes = parse("int some_func(float x);")
    func = nodes.last as Function
    func.name.should eq("some_func")
    func.return_type.should eq(PrimitiveType.new(PrimitiveType::Kind::Int))
    args = func.args
    args.size.should eq(1)
    var = args.first
    var.name.should eq("x")
    var.type.should eq(PrimitiveType.new(PrimitiveType::Kind::Float))
  end

  it "parses function with arg without name" do
    nodes = parse("int some_func(float);")
    func = nodes.last as Function
    func.args.first.name.should eq("")
  end

  it "parses struct" do
    nodes = parse("struct point { int x; int y; };")
    type = nodes.last as StructOrUnion
    type.kind.should eq(:struct)
    type.name.should eq("struct point")
    fields = type.fields
    fields.size.should eq(2)
  end

  it "parses recursive struct" do
    nodes = parse("struct point { struct point* x; };")
    type = nodes.last as StructOrUnion
    type.kind.should eq(:struct)
    type.name.should eq("struct point")
    fields = type.fields
    fields.size.should eq(1)
  end

  it "parses union" do
    nodes = parse("union point { int x; int y; };")
    type = nodes.last as StructOrUnion
    type.kind.should eq(:union)
    type.name.should eq("union point")
    fields = type.fields
    fields.size.should eq(2)
  end

  it "parses unnamed struct" do
    nodes = parse("struct { int x; int y; };")
    type = nodes.last as StructOrUnion
    type.kind.should eq(:struct)
    type.name.should eq("")
    fields = type.fields
    fields.size.should eq(2)
  end

  it "parses typedef" do
    nodes = parse("typedef int foo;")
    typedef = nodes.last as Typedef
    typedef.name.should eq("foo")
    typedef.type.should eq(PrimitiveType.new(PrimitiveType::Kind::Int))
  end

  it "parses typedef struct" do
    nodes = parse("struct foo { int x; int y; }; typedef struct foo point;")
    type = nodes.last as Typedef
    type.name.should eq("point")
    node_ref = type.type as NodeRef
    str = node_ref.node as StructOrUnion
    fields = str.fields
    fields.size.should eq(2)
  end

  it "parses typedef struct" do
    nodes = parse("typedef struct { int x; int y; } point;")
    type = nodes.last as Typedef
    type.name.should eq("point")
    node_ref = type.type as NodeRef
    str = node_ref.node as StructOrUnion
    fields = str.fields
    fields.size.should eq(2)
  end

  it "parses enum" do
    nodes = parse("enum colors { red, green = 10, blue };")
    enum_decl = nodes.last as CrystalLib::Enum
    enum_decl.name.should eq("colors")
    enum_decl.type.should eq(PrimitiveType.new(PrimitiveType::Kind::UInt))
    values = enum_decl.values
    values.size.should eq(3)

    values[0].name.should eq("red")
    values[0].value.should eq(0)

    values[1].name.should eq("green")
    values[1].value.should eq(10)

    values[2].name.should eq("blue")
    values[2].value.should eq(11)
  end

  describe "types" do
    it "parses pointer" do
      nodes = parse("int* some_var;")
      var = nodes.last as Var
      var.name.should eq("some_var")
      var.type.should eq(PointerType.new(PrimitiveType.new(PrimitiveType::Kind::Int)))
    end

    it "parses typedef" do
      nodes = parse("typedef int foo; foo some_var;")
      var = nodes.last as Var
      var.name.should eq("some_var")
      var.type.should eq(TypedefType.new("foo", PrimitiveType.new(PrimitiveType::Kind::Int)))
    end

    # it "parses typedef struct" do
    #   nodes = parse("typedef struct { int x; } foo; foo some_var;")
    #   var = nodes.last as Var
    #   var.name.should eq("some_var")
    #   var.type.should eq(TypedefType.new("foo", PrimitiveType.new(PrimitiveType::Kind::Int)))
    # end
  end
end
