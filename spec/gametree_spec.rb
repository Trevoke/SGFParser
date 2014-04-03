require 'spec_helper'

describe SGF::Gametree do

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

  context 'game-level information' do
    its(:name) { should eq 'Gametree 1: properties' }
    its(:data_entry) { should eq 'Arno Hollosi' }
  end

  it 'should raise errors' do
    expect { subject.opening }.to raise_error(SGF::NoIdentityError)
    expect { subject.nonexistent_identity }.to raise_error(NoMethodError)
  end

  context 'meta information' do
    its(:inspect) { should match(/SGF::Game/) }
    its(:inspect) { should match(/#{game.object_id}/) }
  end

  context "When talking about nodes" do
    its(:current_node) { should eq root_node }

    it "should have a nice way to go to children[0]" do
      subject.next_node
      subject.current_node.should eq subject.root.children[0]
    end

    it "should have a way of setting an arbitrary node to the current node" do
      subject.current_node = subject.root.children[3]
      subject.current_node.properties.keys.sort.should eq %w(B C N)
      subject.current_node.children.size.should eq 6
    end

  end

  context "blocks" do
    it "should use preorder traversal for each" do
      game = get_first_game_from 'spec/data/example1.sgf'
      array = []
      game.each { |node| array << node }
      array[0].c.should eq "root"
      array[1].c.should eq "a"
      array[2].c.should eq "b"
    end

    it "should go through all nodes, even if block returns 'nil' (puts, anyone?)" do
      game = SGF::Gametree.new root_node
      game.root.add_children SGF::Node.new(B: "dd")
      nodes = []
      game.each { |node| nodes << node; nil }
      nodes.size.should eq 2
    end
  end

  context "Slices" do

    it "should return a node-only gametree if slice is [0..0]" do
      game = SGF::Gametree.new root_node
      slice = game.slice(0..0)
      slice.should be_instance_of SGF::Gametree
      slice.root.should eq root_node
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
      slice.should be_instance_of SGF::Gametree
      root = slice.root
      root.b.should eq 'qq'
      root.parent.should be_nil
      root.children[0].a.should eq 'rn'
      root.children[0].children[0].b.should eq 'nr'
    end

  end
end
