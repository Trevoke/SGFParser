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

end
