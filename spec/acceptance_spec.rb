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
    collection = given_a_collection
    game = given_the_first_game_in_the_collection(collection)
    given_black_is_koko(game)

    then_black_should_be_koko(game)
    when_we_save_the_collection(collection, new_file)
    then_black_should_be_koko(collection)
    then_parsing_the_saved_file_should_show_black_is_koko(new_file)
  end

  it 'throws an error if asked to open a non-existing file' do
    expect do
      SGF.parse('some_file.sgf')
    end.to raise_error(SGF::FileDoesNotExistError)
  end


  def given_a_collection
    SGF.parse(full_path_to_file('./data/simple.sgf', starting_point: __FILE__))
  end

  def given_the_first_game_in_the_collection(collection)
    collection.gametrees.first
  end

  def given_black_is_koko(game)
    game.current_node[:PB] = 'kokolegorille'
  end

  def then_black_should_be_koko(game)
    expect(game.current_node[:PB]).to eq 'kokolegorille'
  end

  def when_we_save_the_collection(collection, new_file)
    collection.save(new_file)
  end

  def then_parsing_the_saved_file_should_show_black_is_koko(new_file)
    expect(SGF.parse(new_file).gametrees.first.current_node[:PB]).to eq 'kokolegorille'
  end
end
