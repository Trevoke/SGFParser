require 'spec_helper'

describe "SGF::Tree" do

  before :each do
    @tree = get_tree_from 'spec/data/ff4_ex.sgf'
  end

  it "should have two gametrees" do
    @tree.games.size.should eq 2
  end

  it "should have a decent inspect" do
    inspect = @tree.inspect
    inspect.should match /SGF::Tree/
    inspect.should match /#{@tree.object_id}/
    inspect.should match /2 Games/
    inspect.should match /62 Nodes/
  end

  it "should use preorder traversal for each" do
    @tree = get_tree_from 'spec/data/example1.sgf'
    array = []
    @tree.each { |node| array << node }
    array[0].c.should eq "root"
    array[1].c.should eq "a"
    array[2].c.should eq "b"
  end

  it "should load a file properly" do
    @tree.class.should eq SGF::Tree
    @tree.root.children.size.should eq 2
    @tree.root.children[0].children.size.should eq 5
  end

end
