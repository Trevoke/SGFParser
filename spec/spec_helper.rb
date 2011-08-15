$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'sgf'
require 'rspec'
require 'rspec/autorun'

def get_first_game_from file
  parser = SGF::Parser.new
  tree = parser.parse file
  tree.games.first
end

def get_tree_from file
  parser = SGF::Parser.new
  parser.parse file
end