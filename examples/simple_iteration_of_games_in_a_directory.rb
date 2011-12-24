#Assuming you have the gem installed, of course
require 'sgf'
parser = SGF::Parser.new

Dir['*.sgf'].each do |file|
  tree = parser.parse File.read(file)
  tree.games.each do |game|
    puts "White player: #{game.white_player} and Black player: #{game.black_player}"
  end
  tree.save file #Because may as well indent the files while I'm here, right?
end