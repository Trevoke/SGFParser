require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SGF::Writer" do

  TEMP_FILE = 'spec/data/temp.sgf'

  after :each do
    FileUtils.rm_f TEMP_FILE
  end

  it "should save a simple tree properly" do
    simple_sgf = 'spec/data/simple.sgf'
    tree = get_tree_from simple_sgf
    tree.save TEMP_FILE
    tree2 = get_tree_from TEMP_FILE
    tree.should == tree2
  end

  it "should save an SGF with two gametrees properly" do
    parser = SGF::Parser.new
    sgf_string = "(;FF[4])(;FF[4])"
    tree = parser.parse sgf_string
    tree.save TEMP_FILE
    File.read(TEMP_FILE).should == sgf_string
    tree2 = parser.parse File.read(TEMP_FILE)
    tree.should == tree2
  end

  it "should save the sample SGF properly" do
    parser = SGF::Parser.new
    sgf_string = File.read 'spec/data/ff4_ex.sgf'
    tree = parser.parse sgf_string
    tree.save TEMP_FILE
    tree2 = get_tree_from TEMP_FILE
    tree2.should == tree
  end

end