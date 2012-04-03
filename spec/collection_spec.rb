require 'spec_helper'

describe SGF::Collection do

  before :each do
    @collection = get_collection_from 'spec/data/ff4_ex.sgf'
  end

  it "should have two trees" do
    @collection.gametrees.size.should eq 2
  end

  it "should have a decent inspect" do
    inspect = @collection.inspect
    inspect.should match /SGF::Collection/
    inspect.should match /#{@collection.object_id}/
    inspect.should match /2 Games/
    inspect.should match /62 Nodes/
  end

  it "should use preorder traversal for each" do
    @collection = get_collection_from 'spec/data/example1.sgf'
    array = []
    @collection.each { |node| array << node }
    array[0].c.should eq "root"
    array[1].c.should eq "a"
    array[2].c.should eq "b"
  end

  it "should load a file properly" do
    @collection.should be_an_instance_of SGF::Collection
    @collection.root.children.size.should eq 2
    @collection.root.children[0].children.size.should eq 5
  end

  context "Slices" do
    it "should return a collection with all the children of given depth as root" do
      pending "Must implement slicing on collection"
      root = SGF::Node.new PB: 'Aldric', PW: 'Dosaku'
      node1 = SGF::Node.new C: 'Child 1 of root'
      node2 = SGF::Node.new C: 'Child 2 of root'
      node3 = SGF::Node.new C: 'Child 1 of node1'
      root.add_children node1, node2
      node3.parent = node1
      game = SGF::Gametree.new root
      slice = game.slice(1..2)
      slice.root.children.size.should eq 2
      slice.root.children[0].C.should eq 'Child 1 of root'
      slice.root.children[1].C.should eq 'Child 2 of root'
      slice.root.children[0].children[0].C.should eq 'Child 1 of node1'
    end
  end

end