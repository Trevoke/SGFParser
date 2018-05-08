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
      expect(string[0..99]).to eq "\nboardsize 19\nclear_board\nplay B Q4\nplay W D16\nplay B P17\nplay W E3\nplay B R16\nplay W Q7\nplay B Q10\n"
      expect(string[100..199]).to eq "play W P4\nplay B Q5\nplay W P5\nplay B P3\nplay W O3\nplay B K4\nplay W M4\nplay B G4\nplay W C4\nplay B C9\n"
      expect(string[200..299]).to eq "play W C7\nplay B C12\nplay W K16\nplay B F16\nplay W C14\nplay B J16\nplay W K17\nplay B J17\nplay W N16\npl"
      expect(string[300..399]).to eq "ay B Q6\nplay W P2\nplay B Q3\nplay W N3\nplay B P6\nplay W R10\nplay B R9\nplay W Q11\nplay B Q9\nplay W R11"
      expect(string[400..599]).to eq "\nplay B R7\nplay W Q15\nplay B Q16\nplay W P15\nplay B K15\nplay W J18\nplay B H18\nplay W K18\nplay B E17\nplay W D17\nplay B E18\nplay W D18\nplay B R14\nplay W R15\nplay B S15\nplay W Q13\nplay B S12\nplay W R13\npl"
      expect(string[1400..1599]).to eq "ay B E15\nplay W E16\nplay B F14\nplay W G15\nplay B E7\nplay W O11\nplay B N10\nplay W N11\nplay B M10\nplay W O13\nplay B O12\nplay W K8\nplay B L7\nplay W K6\nplay B J6\nplay W L8\nplay B L6\nplay W N6\nplay B K5\npl"
      expect(string[2000..-1]).to eq " G10\nplay W D15\nplay B J11\nplay W L11\nplay B M12\nplay W K11\nplay B K10\nplay W L10\nplay B Q1\nplay W O1\nplay B G3\nplay W F2\nplay B N7\nplay W N9\nplay B M9\nplay W pass"
    end
  end

  context "the file is coming straight from OGS." do
    it "parses and reprint in GTP" do
      sgf = File.read('spec/data/12098710-203-Patrice-shigazaru.sgf')
      string = save_to_temp_file_and_read(sgf)
      expect(string.size).to eq 2173
      expect(string[0..99]).to eq "\nboardsize 19\nclear_board\nplay B Q4\nplay W D16\nplay B P17\nplay W E3\nplay B R16\nplay W Q7\nplay B Q10\n"
      expect(string[100..199]).to eq "play W P4\nplay B Q5\nplay W P5\nplay B P3\nplay W O3\nplay B K4\nplay W M4\nplay B G4\nplay W C4\nplay B C9\n"
      expect(string[200..299]).to eq "play W C7\nplay B C12\nplay W K16\nplay B F16\nplay W C14\nplay B J16\nplay W K17\nplay B J17\nplay W N16\npl"
      expect(string[300..399]).to eq "ay B Q6\nplay W P2\nplay B Q3\nplay W N3\nplay B P6\nplay W R10\nplay B R9\nplay W Q11\nplay B Q9\nplay W R11"
      expect(string[1000..1199]).to eq " G5\nplay B H6\nplay W E6\nplay B L16\nplay W O18\nplay B O17\nplay W M18\nplay B N17\nplay W M17\nplay B O16\nplay W O15\nplay B N15\nplay W M15\nplay B N14\nplay W M14\nplay B N13\nplay W J15\nplay B K13\nplay W H15\n"
      expect(string[1400..1599]).to eq "ay B E15\nplay W E16\nplay B F14\nplay W G15\nplay B E7\nplay W O11\nplay B N10\nplay W N11\nplay B M10\nplay W O13\nplay B O12\nplay W K8\nplay B L7\nplay W K6\nplay B J6\nplay W L8\nplay B L6\nplay W N6\nplay B K5\npl"
      expect(string[2000..-1]).to eq " G10\nplay W D15\nplay B J11\nplay W L11\nplay B M12\nplay W K11\nplay B K10\nplay W N9\nplay B L10\nplay W J10\nplay B J9\nplay W H9\nplay B H8\nplay W G9\nplay B G11\nplay W E4\nplay B G7"
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
