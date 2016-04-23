require 'spec_helper'

RSpec.describe SGF::Gametree do

  let(:game) { get_first_game_from 'spec/data/ff4_ex.sgf' }
  let(:root_node) {
    SGF::Node.new({FF: '4', AP: 'Primiview:3.1',
                   GM: '1', SZ: '19', GN: 'Gametree 1: properties',
                   US: 'Arno Hollosi'})
  }
  subject { game }

  it 'should throw up if initialized with a non-Node argument' do
    expect { SGF::Gametree.new('I am a string') }.to raise_error(ArgumentError)
    expect { SGF::Gametree.new(SGF::Node.new) }.not_to raise_error
  end

  it 'has game-level information' do
    expect(subject.name).to eq 'Gametree 1: properties'
    expect(subject.data_entry).to eq 'Arno Hollosi'
  end

  it 'should raise errors' do
    expect { subject.opening }.to raise_error(SGF::NoIdentityError)
    expect { subject.nonexistent_identity }.to raise_error(NoMethodError)
  end

  it 'has meta information' do
    expect(subject.inspect).to match(/SGF::Game/)
    expect(subject.inspect).to match(/#{game.object_id}/)
  end

  context "When talking about nodes" do
    it "begins on the root node" do
      expect(subject.current_node).to eq root_node
    end

    it "should have a nice way to go to children[0]" do
      subject.next_node
      expect(subject.current_node).to eq subject.root.children[0]
    end

    it "should have a way of setting an arbitrary node to the current node" do
      subject.current_node = subject.root.children[3]
      expect(subject.current_node.properties.keys).to match_array %w(B C N)
      expect(subject.current_node.children.size).to eq 6
    end

  end

  context "blocks" do
    it "should use preorder traversal for each" do
      game = get_first_game_from 'spec/data/example1.sgf'
      array = []
      game.each { |node| array << node }
      expect(array[0].c).to eq "root"
      expect(array[1].c).to eq "a"
      expect(array[2].c).to eq "b"
    end

    it "should go through all nodes, even if block returns 'nil' (puts, anyone?)" do
      game = SGF::Gametree.new root_node
      game.root.add_children SGF::Node.new(B: "dd")
      nodes = []
      game.each { |node| nodes << node; nil }
      expect(nodes.size).to eq 2
    end
  end

  context "Slices" do

    it "should return a node-only gametree if slice is [0..0]" do
      game = SGF::Gametree.new root_node
      slice = game.slice(0..0)
      expect(slice).to be_instance_of SGF::Gametree
      expect(slice.root).to eq root_node
    end

    it "should slice through a one-branch list" do
      node = SGF::Node.new
      game = SGF::Gametree.new node
      node.pw = 'Aldric'
      child1 = SGF::Node.new b: "qq"
      child2 = SGF::Node.new a: "rn"
      child3 = SGF::Node.new b: "nr"
      node.add_children child1
      child1.add_children child2
      child2.add_children child3
      slice = game.slice(1..3)
      expect(slice).to be_instance_of SGF::Gametree
      root = slice.root
      expect(root.b).to eq 'qq'
      expect(root.parent).to be_nil
      expect(root.children[0].a).to eq 'rn'
      expect(root.children[0].children[0].b).to eq 'nr'
    end

  end
end
