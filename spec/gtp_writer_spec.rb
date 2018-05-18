# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SGF::GtpWriter do
  let(:parser) { SGF::Parser.new }
  let(:suffix) { '' }

  TEMP_FILE = 'spec/data/temp.gtp'

  after { FileUtils.rm_f TEMP_FILE }

  context "the file was modified and saved by sabaki" do
    let(:file) { '12098710-071-Patrice-shigazaru' }
    it "parses and reprint in GTP" do
      subject.upside_down = false
      generate_gtp_and_compare
    end
  end

  context "the file is coming straight from OGS." do
    let(:file) { '12098710-203-Patrice-shigazaru' }
    it "parses and reprint in GTP" do
      subject.upside_down = false
      generate_gtp_and_compare
    end

    context "we want to turn the board upside down" do
      let(:file) { '12098710-203-Patrice-shigazaru' }
      let(:suffix) { '-upside-down' }
      it "parses and reprint in GTP" do
        subject.upside_down = true
        generate_gtp_and_compare
      end
    end

    context "there is an handicap" do
      let(:file) { '12822671-151-MasterSpark-shigazaru' }
      it "parses and reprint in GTP" do
        subject.upside_down = true
        generate_gtp_and_compare
      end
    end

    context "there are 5 handicaps" do
      let(:file) { '12483156-096-Kamilia13-BTRON' }
      it "parses and reprint in GTP" do
        subject.upside_down = true
        generate_gtp_and_compare
      end
    end
  end

  private

  def generate_gtp_and_compare
    sgf = File.read("spec/data/#{file}.sgf")
    string = save_to_temp_file_and_read(sgf)
    expect(string).to eq File.read("spec/data/#{file}#{suffix}.gtp")
  end

  def save_to_temp_file_and_read(string)
    parse_and_save string
    File.read TEMP_FILE
  end

  def parse_and_save(string)
    collection = parser.parse string
    subject.save(collection.root, TEMP_FILE)
    collection
  end
end
