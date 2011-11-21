$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'sgf'
require 'fileutils'
require 'rspec'
require 'rspec/autorun'

def get_first_game_from file
  tree = get_tree_from file
  tree.games.first
end

def get_tree_from file
  parser = SGF::Parser.new
  parser.parse File.read(file)
end