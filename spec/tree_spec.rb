require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SgfParser::Tree" do

  before :each do
    @tree = SgfParser::Tree.new :filename => 'sample_sgf/ff4_ex.sgf'
  end

  it "should parse properly" do
    @tree.class.should == SgfParser::Tree
    @tree.root.children.size.should == 2
    @tree.root.children[0].children.size.should == 5
  end

  it "should save properly" do
    @new = 'sample_sgf/ff4_ex_saved.sgf'
    @tree.save :filename => @new
    @tree2 = SgfParser::Tree.new :filename => @new
    
    @tree2.should == @tree
  end

end
