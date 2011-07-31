require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SgfParser::Tree" do

  include SGF

  it "should load a file properly" do
    tree = Tree.new :filename => 'spec/data/ff4_ex.sgf'
    tree.class.should == Tree
    tree.root.children.size.should == 2
    tree.root.children[0].children.size.should == 5
  end

  it "should save a simple tree properly" do
    tree = Tree.new :filename => 'spec/data/simple.sgf'
    new = 'spec/data/simple_saved.sgf'
    tree.save :filename => new
    tree2 = Tree.new :filename => new
    tree.should == tree2
  end

  it "should save the sample SGF properly" do
    tree = Tree.new :filename => 'spec/data/ff4_ex.sgf'
    new = 'spec/data/ff4_ex_saved.sgf'
    tree.save :filename => new
    tree2 = Tree.new :filename => new
    tree2.should == tree
  end

end
