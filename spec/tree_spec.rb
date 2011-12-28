require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SGF::Tree" do

  before :each do
    @tree = get_tree_from 'spec/data/ff4_ex.sgf'
  end

  it "should have two gametrees" do
    @tree.games.size.should == 2
  end

  it "should tell you the id of the object on inspect" do
    @tree.inspect.should match /#{@tree.object_id}/
  end

  it "should tell you the class of the object on inspect" do
    @tree.inspect.should match /SGF::Tree/
  end

  it "should tell you how many games it has on inspect" do
    @tree.inspect.should match /2 Games/
  end

  it "should tell you how many nodes it has on inspect" do
    @tree.inspect.should match /62 Nodes/
  end

  it "should use preorder traversal for each" do
    @tree = get_tree_from 'spec/data/example1.sgf'
    array = []
    @tree.each {|node| array << node}
    array[0].c.should == "root"
    array[1].c.should == "a"
    array[2].c.should == "b"
  end

  it "should load a file properly" do
    @tree.class.should == SGF::Tree
    @tree.root.children.size.should == 2
    @tree.root.children[0].children.size.should == 5
  end

end
