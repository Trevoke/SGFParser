require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SGF::Node" do

  before :each do
    @node = SGF::Node.new
  end

  it "should be a valid node" do
    @node.class.should == SGF::Node
    @node.properties.should == {}
    @node.parent.should == nil
    @node.children.should == []
  end

  it "should store properties" do
    @node.add_properties "PB" => "Dosaku"
    @node.properties.should == {"PB" => "Dosaku"}
  end

  it "should link to a parent" do
    parent = SGF::Node.new
    @node.parent = parent
    @node.parent.should == parent
  end

  it "should link to children" do
    child1 = SGF::Node.new
    child2 = SGF::Node.new
    child3 = SGF::Node.new
    @node.add_children child1, child2, child3
    @node.children.should == [child1, child2, child3]
  end

  it "should link to children, who should get new parents" do
    child1 = SGF::Node.new
    child2 = SGF::Node.new
    child3 = SGF::Node.new
    @node.add_children child1, child2, child3
    @node.children.each { |child| child.parent.should == @node }
  end

  it "should allow concatenation of properties" do
    @node.add_properties "TC" => "Hello,"
    @node.add_properties "TC" => " world!"
    @node.properties["TC"].should == "Hello, world!"
  end

  it "should give you the properties based on method given" do
    @node.add_properties "PW" => "The Tick"
    @node.add_properties "PB" => "Batmanuel"
    @node.pw.should == "The Tick"
    @node.pb.should == "Batmanuel"
  end

  it "should allow you to change a property completely" do
    @node.add_properties "RE" => "This is made up"
    @node.properties["RE"] = "This is also made up"
    @node.re.should == "This is also made up"
    @node.re = "And that too"
    @node.re.should == "And that too"
  end

  it "should implement [] as a shortcut to read properties" do
    @node.add_properties "PB" => "Dosaku"
    @node["PB"].should == "Dosaku"
    @node[:PB].should == "Dosaku"
  end

  it "should give you a relatively useful inspect" do
    @node.inspect.should match /#{@node.object_id}/
    @node.inspect.should match /SGF::Node/

    @node.add_properties({"C" => "Oh hi", "PB" => "Dosaku", "AE" => "[dd][gh]"})
    @node.inspect.should match /3 Properties/

    @node.add_children SGF::Node.new, SGF::Node.new
    @node.inspect.should match /2 Children/

    @node.inspect.should match /Has no parent/
    @node.parent = SGF::Node.new
    @node.inspect.should match /Has a parent/
  end

  it "should properly show a string version of the node" do
    @node.add_properties({"C" => "Oh hi]", "PB" => "Dosaku"})
    @node.to_str.should == ";C[Oh hi\\]]\nPB[Dosaku]"
  end

  it "should get a node depth number one more by the parent when attached to a parent" do
    child = SGF::Node.new
    @node.add_children child
    @node.depth.should == 0
    child.depth.should == 1
  end

  it "should not be the child of many nodes" do
    parent1 = SGF::Node.new
    parent2 = SGF::Node.new
    parent1.add_children @node
    parent2.add_children @node
    @node.parent.should eq(parent2)
    parent2.children.should include(@node)
    parent1.children.should_not include(@node)
  end

end