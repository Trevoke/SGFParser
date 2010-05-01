require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SgfParser::Tree.parse" do

  before :each do
    @tree = SgfParser::Tree.new :filename => 'sample_sgf/ff4_ex.sgf'
  end

  it "should return true" do
    true
  end

end
