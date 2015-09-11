require "./spec_helper"

private def generate(source)
  nodes = Parser.parse(source)

  io = StringIO.new
  generator = Generator.new("test", "LibPrefix", %w(test_ TEST_), io)
  generator.process(nodes)
  io.to_s
end

describe Generator do
  it "skips non upprcase define" do
    result = generate("#define TEST_hello 1")
    result.should_not contain("hello")
  end

  it "skips redundant define" do
    result = generate("#define TEST_HELLO TEST_HELLO")
    result.should_not contain("HELLO")
  end

  it "skips define if ends with *" do
    result = generate("#define TEST_HELLO some_type*")
    result.should_not contain("HELLO")
  end

  it "skips define if has cast" do
    result = generate("#define TEST_HELLO (size_t)0")
    result.should_not contain("HELLO")
  end

  it "skips define if has macro call" do
    result = generate("#define TEST_HELLO FOO(BAR)")
    result.should_not contain("HELLO")
  end

  it "skips define if references non-existent constant" do
    result = generate("#define TEST_HELLO TEST_BAR")
    result.should_not contain("HELLO")
  end

  it "skips define if contains string piece (1)" do
    result = generate("#define TEST_HELLO foo\"bar\"")
    result.should_not contain("HELLO")
  end

  it "skips define if contains string piece (2)" do
    result = generate("#define TEST_HELLO \"bar\"foo")
    result.should_not contain("HELLO")
  end

  it "generates define" do
    result = generate("#define TEST_HELLO 1 + 2")
    result.should contain("HELLO = 1+2")
  end

  it "generates define and remove redundant parenthesi" do
    result = generate("#define TEST_HELLO (1 + 2)")
    result.should contain("HELLO = 1+2")
  end

  it "generates define that references another one" do
    result = generate("#define TEST_HELLO 1\n#define TEST_BYE TEST_HELLO")
    result.should contain("BYE = HELLO")
  end
end
