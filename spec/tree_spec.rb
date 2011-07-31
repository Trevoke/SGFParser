require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SgfParser::Tree" do

  include SGF

  it "should load a file properly" do
    tree = Parser.new('spec/data/ff4_ex.sgf').parse
    tree.class.should == Tree
    tree.root.children.size.should == 2
    tree.root.children[0].children.size.should == 5
  end

  it "should save a simple tree properly" do
    tree = Parser.new('spec/data/simple.sgf').parse
    new_file = 'spec/data/simple_saved.sgf'
    tree.save :filename => new_file
    tree2 = Parser.new(new_file).parse
    tree.should == tree2
  end

  it "should save the sample SGF properly" do
    tree = Parser.new('spec/data/ff4_ex.sgf').parse
    new_file = 'spec/data/ff4_ex_saved.sgf'
    tree.save :filename => new_file
    tree2 = Parser.new(new_file).parse
    tree2.should == tree
  end

end
