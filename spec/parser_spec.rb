require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SGF::Parser" do

  it "should give an error if the first two character are not (;" do
    parser = SGF::Parser.new
    expect { parser.parse ';)' }.to raise_error SGF::MalformedDataError
  end

  it "should not give an error if it is told to sit down and shut up" do
    parser = SGF::Parser.new false
    pending "Read Rspec doc to find equivalent of assert_raises_nothing"
    expect { parser.parse ';)'}.to raise_nothing
  end

  it "should parse a simple node" do
    parser = SGF::Parser.new false
    tree = parser.parse ";PW[5]"
    tree.root.children[0].pw.should == "5"
  end

  it "should parse a node with two properties" do
    parser = SGF::Parser.new false
    tree = parser.parse ";PB[Aldric]PW[Bob]"
    tree.root.children[0].pb.should == "Aldric"
    tree.root.children[0].pw.should == "Bob"
  end

  it "should parse two nodes with one property each" do
    parser = SGF::Parser.new false
    tree = parser.parse ";PB[Aldric];PW[Bob]"
    node = tree.root.children[0]
    p node
    node.pb.should == "Aldric"
    node.children[0].pw.should == "Bob"
  end

end
