# frozen_string_literal: true

# Assuming you have the gem installed, of course
require 'sgf'
parser = SGF::Parser.new

Dir['*.sgf'].each do |file|
  collection = parser.parse File.read(file)
  collection.gametrees.each do |game|
    puts "White player: #{game.white_player} and Black player: #{game.black_player}"
  end
  collection.save file # Because may as well indent the files while I'm here, right?
end
