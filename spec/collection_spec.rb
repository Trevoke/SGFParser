require 'spec_helper'

describe SGF::Collection do

  let(:collection) { get_collection_from 'spec/data/ff4_ex.sgf' }
  subject { collection }

  it "has two games" do
    expect(subject.gametrees.size).to eq 2
  end

  context 'on the gametree level' do
    subject { collection.root }
    it "should have two children" do
      expect(subject.children.size).to eq 2
    end

    context 'in the first gametree' do
      subject { collection.root.children[0] }
      it "should have five children" do
        expect(subject.children.size).to eq 5
      end
    end
  end

  context "inspect" do
    subject { collection.inspect }
    it { should match(/SGF::Collection/) }
    it { should match(/#{collection.object_id}/) }
    it { should match(/2 Games/) }
    it { should match(/62 Nodes/) }
  end

  it "should use preorder traversal for each" do
    collection = get_collection_from 'spec/data/example1.sgf'
    array = []
    collection.each { |node| array << node }
    array[0].c.should eq "root"
    array[1].c.should eq "a"
    array[2].c.should eq "b"
  end

  it "should properly compare two collections" do
    new_collection = get_collection_from 'spec/data/ff4_ex.sgf'
    expect(collection).to eq new_collection
  end

end
