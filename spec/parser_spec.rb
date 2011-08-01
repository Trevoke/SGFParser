require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SGF::Parser" do

  it "should have FF in the first node" do
    tree = SGF::Parser.new('spec/data/ff4_ex.sgf').parse
    tree.root.children[0].properties.keys.should include("FF")
  end

  it "should give an error if FF is missing from the first node" do
    pending "To be coded later"
  end

  it "should parse properly the AW property" do
    sgf = "dd][de][ef]"
    parser = SGF::Parser.new sgf
    parser.get_property.should == "[dd][de][ef]"
  end

end
