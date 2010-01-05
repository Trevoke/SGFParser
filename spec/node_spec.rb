require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SgfParser::Node" do
  before :each do
    @node = SgfParser::Node.new
  end

  it "should be a valid node" do
    @node.class.should == SgfParser::Node
    @node.properties.should == {}
    @node.parent.should == nil
    @node.children.should == []
  end

  it "should store properties" do
    @node.add_properties "PB" => "Dosaku"
    @node.properties.should == {"PB" => "Dosaku"}
  end

  it "should link to a parent" do
    parent = SgfParser::Node.new
    @node.parent = parent
    @node.parent.should == parent
  end

  it "should link to children" do
    child1 = SgfParser::Node.new
    child2 = SgfParser::Node.new
    child3 = SgfParser::Node.new
    @node.add_children child1, child2, child3
    @node.children.should == [child1, child2, child3]
  end

end