require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SGF::Tree" do

  before :each do
    @tree = get_tree_from 'spec/data/ff4_ex.sgf'
  end

  after :each do
    FileUtils.rm_f 'spec/data/simple_saved.sgf'
    FileUtils.rm_f 'spec/data/ff4_ex_saved.sgf'
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
    @tree.inspect.should match /Games: 2/
  end

  it "should tell you how many nodes it has on inspect" do
    @tree.inspect.should match /Nodes: 62/
  end

  it "should use preorder traversal for each" do
    @tree = get_tree_from 'spec/data/example1.sgf'
    array = []
    @tree.each {|node| array << node}
    array[0].c.should == "[root]"
    array[1].c.should == "[a]"
    array[2].c.should == "[b]"
  end

  it "should load a file properly" do
    @tree.class.should == SGF::Tree
    @tree.root.children.size.should == 2
    @tree.root.children[0].children.size.should == 5
  end

  it "should save a simple tree properly" do
    simple_sgf = 'spec/data/simple.sgf'
    tree = get_tree_from simple_sgf
    new_file = 'spec/data/simple_saved.sgf'
    tree.save :filename => new_file
    tree2 = get_tree_from new_file
    tree.should == tree2
  end

  it "should save the sample SGF properly" do
    new_file = 'spec/data/ff4_ex_saved.sgf'
    @tree.save :filename => new_file
    tree2 = get_tree_from new_file
    tree2.should == @tree
  end

end
