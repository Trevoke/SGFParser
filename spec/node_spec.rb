require 'spec_helper'

RSpec.describe SGF::Node do

  let(:node) { SGF::Node.new }
  subject { node }

  context 'inspect' do
    subject { node.inspect }
    it { is_expected.to match(/#{node.object_id}/) }
    it { is_expected.to match(/SGF::Node/) }
    it { is_expected.to match(/Has no parent/) }

    it "should give you a relatively useful inspect" do
      node.add_properties({C: "Oh hi", PB: "Dosaku", AE: "[dd][gh]"})
      is_expected.to match(/3 Properties/)

      node.add_children SGF::Node.new, SGF::Node.new
      expect(node.inspect).to match(/2 Children/)

      node.parent = SGF::Node.new
      expect(node.inspect).to match(/Has a parent/)
    end

  end

  it "should properly show a string version of the node" do
    subject.add_properties({"C" => "Oh hi]", "PB" => "Dosaku"})
    expect(subject.to_str).to eq ";C[Oh hi\\]]\nPB[Dosaku]"
  end

  it "should properly show a string version of the node if identities are symbols" do
    subject.add_properties({C: "Oh hi]", PB: "Dosaku"})
    expect(subject.to_str).to eq ";C[Oh hi\\]]\nPB[Dosaku]"
  end

  context "Heredity" do

    let(:parent) { SGF::Node.new }
    let(:child1) { SGF::Node.new }
    let(:child3) { SGF::Node.new }
    let(:child2) { SGF::Node.new }

    it "should link to a parent" do
      subject.parent = parent
      expect(subject.parent).to eq parent
    end

    it "should link to children" do
      node.add_children child1, child2, child3
      expect(node.children).to eq [child1, child2, child3]
    end

    it "should link to children, who should get new parents" do
      node.add_children child1, child2, child3
      node.children.each { |child| expect(child.parent).to eq node }
    end

    it "should not be the child of many nodes" do
      parent2 = SGF::Node.new
      parent.add_children node
      parent2.add_children node
      expect(node.parent).to eq(parent2)
      expect(parent2.children).to include(node)
      expect(parent.children).to_not include(node)
    end

    it "should become a child of its new parent" do
      node.parent = parent
      expect(parent.children).to include node
    end

  end

  context "Properties" do

    it "should store properties" do
      node.add_properties PB: "Dosaku"
      expect(node.properties).to eq({"PB" => "Dosaku"})
    end

    it "should allow concatenation of properties" do
      node.add_properties "TC" => "Hello,"
      node.add_properties "TC" => " world!"
      expect(node.properties["TC"]).to eq "Hello, world!"
    end

    it "should give you the properties based on method given" do
      node.add_properties "PW" => "The Tick"
      node.add_properties "PB" => "Batmanuel"
      expect(node.pw).to eq "The Tick"
      expect(node.pb).to eq "Batmanuel"
    end

    it "should allow you to change a property completely" do
      node.add_properties "RE" => "This is made up"
      node.properties["RE"] = "This is also made up"
      expect(node.re).to eq "This is also made up"
      node.re = "And that too"
      expect(node.re).to eq "And that too"
      node[:RE] = 'kokolegorille'
      expect(node[:RE]).to eq 'kokolegorille'
    end

    it "should implement [] as a shortcut to read properties" do
      node.add_properties "PB" => "Dosaku"
      expect(node["PB"]).to eq "Dosaku"
      expect(node[:PB]).to eq "Dosaku"
    end

  end

  context "Node depth" do

    it "should get a node depth number one more by the parent when attached to a parent" do
      child = SGF::Node.new
      node.add_children child
      expect(node.depth).to eq 0
      expect(child.depth).to eq 1
    end

    it "should properly set depth if a parent is passed to initializer" do
      node2 = SGF::Node.new parent: node
      expect(node2.parent).to eq node
      expect(node2.depth).to eq 1
    end

    it "should properly update depth when parentage changes" do
      link1 = SGF::Node.new
      link2 = SGF::Node.new
      link2.parent = link1
      link1.parent = node
      expect(node.parent).to be_nil
      expect(link1.parent).to eq node
      expect(link2.parent).to eq link1
      expect(node.depth).to eq 0
      expect(link1.depth).to eq 1
      expect(link2.depth).to eq 2
    end

    it "should properly update depth if parent is set to nil / parent is removed" do
      parent = SGF::Node.new
      child = SGF::Node.new

      node.add_children child
      node.parent = parent
      expect(node.depth).to eq 1
      expect(child.depth).to eq 2

      node.parent = nil
      expect(node.depth).to eq 0
      expect(child.depth).to eq 1

      node.parent = parent
      expect(node.depth).to eq 1
      expect(child.depth).to eq 2

      node.remove_parent
      expect(node.depth).to eq 0
      expect(child.depth).to eq 1
    end

    it "should properly update depth when childhood changes" do
      link1 = SGF::Node.new
      link2 = SGF::Node.new
      link3 = SGF::Node.new
      link1.add_children link2
      link2.add_children link3
      node.add_children link1
      node.add_children link3
      expect(node.depth).to eq 0
      expect(link1.depth).to eq 1
      expect(link2.depth).to eq 2
      expect(link3.depth).to eq 1
    end
  end

  context "self-consistency" do
    it "should only track  changes from its current parent" do
      link1 = SGF::Node.new
      link2 = SGF::Node.new

      link3 = SGF::Node.new
      link1.add_children link2
      node.parent = link2
      expect(node.depth).to eq 2

      link1.depth = 2
      expect(node.depth).to eq 4

      node.parent = link3
      link1.depth = 6
      expect(node.depth).to eq 1
    end
  end
end
