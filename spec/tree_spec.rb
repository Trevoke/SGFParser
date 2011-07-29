require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SgfParser::Tree" do

  before :each do

  end

  it "should parse properly" do
    tree = SgfParser::Tree.new :filename => 'sample_sgf/ff4_ex.sgf'
    tree.class.should == SgfParser::Tree
    tree.root.children.size.should == 2
    tree.root.children[0].children.size.should == 5
  end

  it "should save a simple tree properly" do
    tree = SgfParser::Tree.new :filename => 'sample_sgf/simple.sgf'
    new = 'sample_sgf/simple_saved.sgf'
    tree.save :filename => new
    tree2 = SgfParser::Tree.new :filename => new
    tree.should == tree2
  end

  it "should save the sample SGF properly" do
    tree = SgfParser::Tree.new :filename => 'sample_sgf/ff4_ex.sgf'
    new = 'sample_sgf/ff4_ex_saved.sgf'
    tree.save :filename => new
    tree2 = SgfParser::Tree.new :filename => new
    tree_children = []
    tree2_children = []
    tree.each { |node| tree_children << node }
    tree2.each { |node| tree2_children << node }
    tree_children.size.should == tree2_children.size
    tree_children.each_with_index do |node, index|
      node.properties.should == tree2_children[index].properties
    end
    tree_children.should == tree2_children
    tree2.should == tree
  end

end
