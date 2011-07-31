require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SgfParser::Node" do

  include SGF

  before :each do
    @node = Node.new
  end

  it "should be a valid node" do
    @node.class.should == Node
    @node.properties.should == {}
    @node.parent.should == nil
    @node.children.should == []
  end

  it "should store properties" do
    @node.add_properties "PB" => "Dosaku"
    @node.properties.should == {"PB" => "Dosaku"}
  end

  it "should link to a parent" do
    parent = Node.new
    @node.parent = parent
    @node.parent.should == parent
  end

  it "should link to children" do
    child1 = Node.new
    child2 = Node.new
    child3 = Node.new
    @node.add_children child1, child2, child3
    @node.children.should == [child1, child2, child3]
  end

  it "should link to children, who should get new parents" do
    child1 = Node.new
    child2 = Node.new
    child3 = Node.new
    @node.add_children child1, child2, child3
    @node.children.each { |child| child.parent.should == @node }
  end

end