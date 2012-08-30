require 'spec_helper'

describe SGF::Collection do

  let(:collection) { get_collection_from 'spec/data/ff4_ex.sgf' }
  subject { collection }

  its(:gametrees) { should have(2).games }

  context 'data under the root' do
    subject { collection.root }
    its(:children) { should have(2).nodes }
    context 'another step down' do
      subject { collection.root.children[0] }
      its(:children) { should have(5).nodes }
    end
  end

  context "inspect" do
    subject { collection.inspect }
    it { should match /SGF::Collection/ }
    it { should match /#{collection.object_id}/ }
    it { should match /2 Games/ }
    it { should match /62 Nodes/ }
  end

  it "should use preorder traversal for each" do
    collection = get_collection_from 'spec/data/example1.sgf'
    array = []
    collection.each { |node| array << node }
    array[0].c.should eq "root"
    array[1].c.should eq "a"
    array[2].c.should eq "b"
  end

end
