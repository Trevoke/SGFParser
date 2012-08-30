require 'spec_helper'

describe SGF::Node do

  let(:node) { SGF::Node.new }
  subject { node }

  context 'inspect' do
    subject { node.inspect }
    it { should match /#{node.object_id}/ }
    it { should match /SGF::Node/ }
    it { should match /Has no parent/ }

    it "should give you a relatively useful inspect" do
      node.add_properties({C: "Oh hi", PB: "Dosaku", AE: "[dd][gh]"})
      should match /3 Properties/

      node.add_children SGF::Node.new, SGF::Node.new
      node.inspect.should match /2 Children/

      node.parent = SGF::Node.new
      node.inspect.should match /Has a parent/
    end

  end

  it "should properly show a string version of the node" do
    subject.add_properties({"C" => "Oh hi]", "PB" => "Dosaku"})
    subject.to_str.should eq ";C[Oh hi\\]]\nPB[Dosaku]"
  end

  it "should properly show a string version of the node if identities are symbols" do
    subject.add_properties({C: "Oh hi]", PB: "Dosaku"})
    subject.to_str.should eq ";C[Oh hi\\]]\nPB[Dosaku]"
  end

  context "Heredity" do

    let(:parent) { SGF::Node.new }
    let(:child1) { SGF::Node.new }
    let(:child3) { SGF::Node.new }
    let(:child2) { SGF::Node.new }

    it "should link to a parent" do
      subject.parent = parent
      subject.parent.should eq parent
    end

    it "should link to children" do
      node.add_children child1, child2, child3
      node.children.should eq [child1, child2, child3]
    end

    it "should link to children, who should get new parents" do
      node.add_children child1, child2, child3
      node.children.each { |child| child.parent.should eq node }
    end

    it "should not be the child of many nodes" do
      parent2 = SGF::Node.new
      parent.add_children node
      parent2.add_children node
      node.parent.should eq(parent2)
      parent2.children.should include(node)
      parent.children.should_not include(node)
    end

    it "should become a child of its new parent" do
      node.parent = parent
      parent.children.should include node
    end

  end

  context "Properties" do

    it "should store properties" do
      node.add_properties PB: "Dosaku"
      node.properties.should eq({"PB" => "Dosaku"})
    end

    it "should allow concatenation of properties" do
      node.add_properties "TC" => "Hello,"
      node.add_properties "TC" => " world!"
      node.properties["TC"].should eq "Hello, world!"
    end

    it "should give you the properties based on method given" do
      node.add_properties "PW" => "The Tick"
      node.add_properties "PB" => "Batmanuel"
      node.pw.should eq "The Tick"
      node.pb.should eq "Batmanuel"
    end

    it "should allow you to change a property completely" do
      node.add_properties "RE" => "This is made up"
      node.properties["RE"] = "This is also made up"
      node.re.should eq "This is also made up"
      node.re = "And that too"
      node.re.should eq "And that too"
    end

    it "should implement [] as a shortcut to read properties" do
      node.add_properties "PB" => "Dosaku"
      node["PB"].should eq "Dosaku"
      node[:PB].should eq "Dosaku"
    end

  end

  context "Node depth" do

    it "should get a node depth number one more by the parent when attached to a parent" do
      child = SGF::Node.new
      node.add_children child
      node.depth.should eq 0
      child.depth.should eq 1
    end

    it "should properly set depth if a parent is passed to initializer" do
      node2 = SGF::Node.new parent: node
      node2.parent.should eq node
      node2.depth.should eq 1
    end

    it "should properly update depth when parentage changes" do
      link1 = SGF::Node.new
      link2 = SGF::Node.new
      link2.parent = link1
      link1.parent = node
      node.parent.should be_nil
      link1.parent.should eq node
      link2.parent.should eq link1
      node.depth.should eq 0
      link1.depth.should eq 1
      link2.depth.should eq 2
    end

    it "should properly update depth if parent is set to nil / parent is removed" do
      parent = SGF::Node.new
      child = SGF::Node.new

      node.add_children child
      node.parent = parent
      node.depth.should eq 1
      child.depth.should eq 2

      node.parent = nil
      node.depth.should eq 0
      child.depth.should eq 1

      node.parent = parent
      node.depth.should eq 1
      child.depth.should eq 2

      node.remove_parent
      node.depth.should eq 0
      child.depth.should eq 1
    end

    it "should properly update depth when childhood changes" do
      link1 = SGF::Node.new
      link2 = SGF::Node.new
      link3 = SGF::Node.new
      link1.add_children link2
      link2.add_children link3
      node.add_children link1
      node.add_children link3
      node.depth.should eq 0
      link1.depth.should eq 1
      link2.depth.should eq 2
      link3.depth.should eq 1
    end
  end
end
