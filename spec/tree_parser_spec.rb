require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SgfParser::Tree.parse" do

  include SGF

  it "should have FF in the first node" do
    tree = Tree.new :filename => 'spec/data/ff4_ex.sgf'
    tree.root.children[0].properties.keys.should include("FF")
  end

  it "should give an error if FF is missing from the first node" do
    pending "To be coded later"
  end

  it "should parse properly the AW property" do
    input = StringIO.new "dd][de][ef]"
    tree = Tree.new
    tree.instance_variable_set "@stream", input
    tree.get_property.should == "[dd][de][ef]"
  end

end
