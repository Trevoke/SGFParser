require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SGF::Parser" do

  it "should give an error if the first two character are not (;" do
    parser = strict_parser
    expect { parser.parse ';)' }.to raise_error SGF::MalformedDataError
  end

  it "should not give an error if it is told to sit down and shut up" do
    parser = lenient_parser
    pending "Read Rspec doc to find equivalent of assert_raises_nothing"
    expect { parser.parse ';)'}.to raise_nothing
  end

  it "should parse a simple node" do
    parser = lenient_parser
    tree = parser.parse ";PW[5]"
    tree.root.children[0].pw.should == "5"
  end

  it "should parse a node with two properties" do
    parser = lenient_parser
    tree = parser.parse ";PB[Aldric]PW[Bob]"
    tree.root.children[0].pb.should == "Aldric"
    tree.root.children[0].pw.should == "Bob"
  end

  it "should parse two nodes with one property each" do
    parser = lenient_parser
    tree = parser.parse ";PB[Aldric];PW[Bob]"
    node = tree.root.children[0]
    node.pb.should == "Aldric"
    node.children[0].pw.should == "Bob"
  end

  it "should parse a tree with a single branch" do
    parser = strict_parser
    tree = parser.parse "(;FF[4]PW[Aldric]PB[Bob];B[qq])"
    node = tree.root.children[0]
    node.pb.should == "Bob"
    node.pw.should == "Aldric"
    node.children[0].b.should == "qq"
  end

  it "should parse a tree with two branches" do
    parser = strict_parser
    tree = parser.parse "(;FF[4](;C[main])(;C[branch]))"
    node = tree.root.children[0]
    node.ff.should == "4"
    node.children.size.should == 2
    node.children[0].c.should == "main"
    node.children[1].c.should == "branch"
  end

  it "should parse a comment with a ] inside" do
    parser = strict_parser
    tree = parser.parse "(;C[Oh hi\\] there]"
    tree.root.children[0].c.should == "Oh hi] there"
  end

  it "should parse a multi-property identity well" do
    parser = strict_parser
    tree = parser.parse "(;FF[4];AW[bd][cc][qr])"
    tree.root.children[0].children[0].aw.should == ["bd", "cc", "qr"]
  end

  it "should parse multiple trees" do
    parser = strict_parser
    tree = parser.parse "(;FF[4];AW[dd][cc])(;FF[4];PB[ad])"
    tree.root.children.size.should == 2
    tree.root.children[0].children[0].aw.should == ["dd", "cc"]
    tree.root.children[1].children[0].pb.should == "ad"
  end

  private

  def lenient_parser
    SGF::Parser.new false
  end

  def strict_parser
    SGF::Parser.new
  end

end
