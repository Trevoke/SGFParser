require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SGF::Tree" do

  before :each do
    @tree = SGF::Parser.new('spec/data/ff4_ex.sgf').parse
  end

  it "should load a file properly" do
    @tree.class.should == SGF::Tree
    @tree.root.children.size.should == 2
    @tree.root.children[0].children.size.should == 5
  end

  it "should save a simple tree properly" do
    tree = SGF::Parser.new('spec/data/simple.sgf').parse
    new_file = 'spec/data/simple_saved.sgf'
    tree.save :filename => new_file
    tree2 = SGF::Parser.new(new_file).parse
    tree.should == tree2
  end

  it "should save the sample SGF properly" do
    new_file = 'spec/data/ff4_ex_saved.sgf'
    @tree.save :filename => new_file
    tree2 = SGF::Parser.new(new_file).parse
    tree2.should == @tree
  end

  it "should have 'root' as the default current node" do
    @tree.current_node.should == @tree.root
  end

  it "should have a way of setting an arbitrary node to the current node" do
    @tree.current_node = @tree.root.children[0].children[3]
    @tree.current_node.properties.keys.sort.should == ["B", "C", "N"]
    @tree.current_node.children.size.should == 6
  end

  it "should have a nice way to go to children[0]" do
    @tree.next_node
    @tree.current_node.should == @tree.root.children[0]
  end

end
