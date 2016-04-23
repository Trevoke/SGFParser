require 'rspec'
require_relative '../lib/sgf'

def full_path_to_file(relative_file_path)
  File.expand_path(File.join(File.dirname(__FILE__), relative_file_path))
end

RSpec.describe 'End To End' do
  let(:new_file) { full_path_to_file('./simple_changed.sgf') }

  after do
    File.delete(new_file)
  end

  it 'should modify an object and save the changes' do
    collection = SGF.parse(full_path_to_file('./data/simple.sgf'))
    game = collection.gametrees.first
    game.current_node[:PB] = 'kokolegorille'

    expect(game.current_node[:PB]).to eq 'kokolegorille'
    collection.save(new_file)
    expect(game.current_node[:PB]).to eq 'kokolegorille'
    expect(SGF.parse(new_file).gametrees.first.current_node[:PB]).to eq 'kokolegorille'
  end
end
