# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SGF::Writer do
  let(:parser) { SGF::Parser.new }

  TEMP_FILE = 'spec/data/temp.sgf'

  after { FileUtils.rm_f TEMP_FILE }

  it 'should save a simple tree properly' do
    sgf = File.read('spec/data/simple.sgf')
    parse_save_load_and_compare_to_saved sgf
  end

  it 'should save an SGF with two gametrees properly' do
    parse_save_load_and_compare_to_saved '(;FF[4])(;FF[4])'
  end

  it 'should save the one-line simplified sample' do
    parse_save_load_and_compare_to_saved ONE_LINE_SIMPLE_SAMPLE_SGF
  end

  it 'should save the simplified SGF properly' do
    parse_save_load_and_compare_to_saved SIMPLIFIED_SAMPLE_SGF
  end

  it 'should save the sample SGF properly' do
    sgf = File.read('spec/data/ff4_ex.sgf')
    parse_save_load_and_compare_to_saved sgf
  end

  it 'should indent a simple SGF nicely' do
    sgf = save_to_temp_file_and_read '(;FF[4])'
    expect(sgf).to eq "\n(\n  ;FF[4]\n)"
  end

  it 'should indent a one-node SGF with two properties' do
    sgf = save_to_temp_file_and_read '(;FF[4]PW[Cho Chikun])'
    expect(sgf).to eq "\n(\n  ;FF[4]\n  PW[Cho Chikun]\n)"
  end

  it 'should indent two nodes on same column' do
    sgf = save_to_temp_file_and_read '(;FF[4];PB[qq])'
    expect(sgf).to eq "\n(\n  ;FF[4]\n  ;PB[qq]\n)"
  end

  it 'should indent branches further' do
    string = '(;FF[4](;PB[qq])(;PB[qa]))'
    sgf = save_to_temp_file_and_read string
    expected = %{
(
  ;FF[4]
  (
    ;PB[qq]
  )
  (
    ;PB[qa]
  )
)}
    expect(sgf).to eq expected
  end

  it 'should indent two gametrees' do
    string = '(;FF[4];PB[qq])(;FF[4];PB[dd])'
    sgf = save_to_temp_file_and_read string
    expected = %{
(
  ;FF[4]
  ;PB[qq]
)
(
  ;FF[4]
  ;PB[dd]
)}
    expect(sgf).to eq expected
  end

  it 'should save to a StringIO object' do
    collection = parser.parse '(;FF[4]PW[Dosaku])'
    output = StringIO.new
    SGF::Writer.new.save(collection.root, output)
    output.rewind
    saved_content = output.read
    expect(saved_content).to include 'FF[4]'
    expect(saved_content).to include 'PW[Dosaku]'
  end

  it 'should save to any IO-like object with write method' do
    collection = parser.parse '(;FF[4]PW[Dosaku])'
    io_like = Class.new do
      def initialize
        @content = +'' # unary plus unfreezes the string
      end
      def write(data)
        @content << data
      end
      def to_s
        @content
      end
    end.new

    SGF::Writer.new.save(collection.root, io_like)
    saved_content = io_like.to_s
    expect(saved_content).to include 'FF[4]'
    expect(saved_content).to include 'PW[Dosaku]'
  end

  private

  def parse_save_load_and_compare_to_saved(string)
    collection = parse_and_save string
    collection2 = get_collection_from TEMP_FILE
    expect(collection2).to eq collection
  end

  def save_to_temp_file_and_read(string)
    parse_and_save string
    File.read TEMP_FILE
  end

  def parse_and_save(string)
    collection = parser.parse string
    collection.save TEMP_FILE
    collection
  end
end
