# typed: false
# frozen_string_literal: true

require 'rspec'
require_relative '../lib/sgf'

RSpec.describe 'End To End' do
  let(:new_file) { full_path_to_file('./simple_changed.sgf', starting_point: __FILE__) }

  after do
    File.delete(new_file) if File.exist?(new_file)
  end

  it 'should modify an object and save the changes' do
    collection = SGF.parse(full_path_to_file('./data/simple.sgf', starting_point: __FILE__))
    game = collection.gametrees.first
    game.current_node[:PB] = 'kokolegorille'

    expect(game.current_node[:PB]).to eq 'kokolegorille'
    collection.save(new_file)
    expect(game.current_node[:PB]).to eq 'kokolegorille'
    expect(SGF.parse(new_file).gametrees.first.current_node[:PB]).to eq 'kokolegorille'
  end

  it 'throws an error if asked to open a non-existing file' do
    expect do
      SGF.parse('some_file.sgf')
    end.to raise_error(SGF::FileDoesNotExistError)
  end
end
