require 'spec_helper'

describe SGF::Writer do

  TEMP_FILE = 'spec/data/temp.sgf'

  after :each do
    FileUtils.rm_f TEMP_FILE
  end

  it "should save a simple tree properly" do
    sgf = File.read('spec/data/simple.sgf')
    parse_save_load_and_compare_to_saved sgf
  end

  it "should save an SGF with two gametrees properly" do
    parse_save_load_and_compare_to_saved "(;FF[4])(;FF[4])"
  end

  it "should save the one-line simplified sample" do
    parse_save_load_and_compare_to_saved ONE_LINE_SIMPLE_SAMPLE_SGF
  end

  it "should save the simplified SGF properly" do
    parse_save_load_and_compare_to_saved SIMPLIFIED_SAMPLE_SGF
  end

  it "should save the sample SGF properly" do
    sgf = File.read('spec/data/ff4_ex.sgf')
    parse_save_load_and_compare_to_saved sgf
  end

  it "should indent a simple SGF nicely" do
    sgf = save_to_temp_file_and_read '(;FF[4])'
    sgf.should eq "\n(\n  ;FF[4]\n)"
  end

  it "should indent a one-node SGF with two properties" do
    sgf = save_to_temp_file_and_read '(;FF[4]PW[Cho Chikun])'
    sgf.should eq "\n(\n  ;FF[4]\n  PW[Cho Chikun]\n)"
  end

  it "should indent two nodes on same column" do
    sgf = save_to_temp_file_and_read '(;FF[4];PB[qq])'
    sgf.should eq "\n(\n  ;FF[4]\n  ;PB[qq]\n)"
  end

  it "should indent branches further" do
    string = '(;FF[4](;PB[qq])(;PB[qa]))'
    sgf = save_to_temp_file_and_read string
    expected = %Q{
(
  ;FF[4]
  (
    ;PB[qq]
  )
  (
    ;PB[qa]
  )
)}
    sgf.should eq expected
  end

  it "should indent two gametrees" do
    string = '(;FF[4];PB[qq])(;FF[4];PB[dd])'
    sgf = save_to_temp_file_and_read string
    expected = %Q{
(
  ;FF[4]
  ;PB[qq]
)
(
  ;FF[4]
  ;PB[dd]
)}
    sgf.should eq expected
  end

  private

  def parse_save_load_and_compare_to_saved string
    parser =SGF::Parser.new
    collection = parser.parse string
    collection.save TEMP_FILE
    collection2 = get_collection_from TEMP_FILE
    collection2.should eq collection
  end


  def save_to_temp_file_and_read sgf_string
    collection = SGF::Parser.new.parse sgf_string
    collection.save TEMP_FILE
    File.read TEMP_FILE
  end

end
