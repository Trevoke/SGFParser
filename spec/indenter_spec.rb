require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SGF::Indenter" do

  it "should nicely show a single node with one property" do
    indenter = SGF::Indenter.new '(;FF[4])'
    new_string = indenter.parse
    new_string.should == "\n  (\n  ;FF[4]\n  )\n"
  end

  it "should indent nicely a slightly more complex example" do
    pending "When I have the courage to write out the test output"
  end
end