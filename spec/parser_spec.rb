require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SGF::Parser" do

  before :each do
    @parser = SGF::Parser.new
  end

  #it "should have FF in the first node" do
  #  tree = @parser.parse 'spec/data/ff4_ex.sgf'
  #  tree.root.children[0].properties.keys.should include("FF")
  #end

  it "should give an error if the first character is not (" do
    tree = @parser.parse ';)'
    tree.errors.should include?(SGF::MalformedDataError)
    tree.errors[0].message.should == "The first character is not '('."
  end

  it "should parse a very simple tree" do
    tree = @parser.parse '(;FF[4];W[qd])'
    game_root = tree.root.children[0]
    game_root.properties.should == {"FF" => "[4]"}
    game_root.children[0].properties.should == {"W" => "[qd]"}
  end

end
