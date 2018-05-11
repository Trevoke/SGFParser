require 'spec_helper'
require 'byebug'

RSpec.describe SGF::GtpWriter do

  let(:parser) { SGF::Parser.new }

  TEMP_FILE = 'spec/data/temp.gtp'

  after { FileUtils.rm_f TEMP_FILE }

  context "the file was modified and saved by sabaki" do
    it "parses and reprint in GTP" do
      sgf = File.read('spec/data/12098710-071-Patrice-shigazaru.sgf')
      string = save_to_temp_file_and_read(sgf)
      expect(string.size).to eq 2163
      expect(string).to eq File.read('spec/data/12098710-071-Patrice-shigazaru.gtp')
    end
  end

  context "the file is coming straight from OGS." do
    it "parses and reprint in GTP" do
      sgf = File.read('spec/data/12098710-203-Patrice-shigazaru.sgf')
      string = save_to_temp_file_and_read(sgf)
      expect(string).to eq File.read('spec/data/12098710-203-Patrice-shigazaru.gtp')
    end
  end

  private

  def save_to_temp_file_and_read string
    parse_and_save string
    File.read TEMP_FILE
  end

  def parse_and_save string
    collection = parser.parse string
    subject.save(collection.root, TEMP_FILE)
    collection
  end

end
