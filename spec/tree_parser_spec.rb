require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SgfParser::Tree.parse" do

  before :each do
    @tree = SgfParser::Tree.new :filename => 'sample_sgf/ff4_ex.sgf'
  end

  it "should have FF in the first node" do
    @tree.root.children[0].properties.keys.should include("FF")
  end

  it "should give an error if FF is missing from the first node" do
    pending "To be coded later"
  end

  it "should parse properly the AW property" do
    input = StringIO.new "dd][de][ef]"
    tree = SgfParser::Tree.new
    tree.instance_variable_set "@stream", input
    tree.get_property.should == "[dd][de][ef]"
  end

end
