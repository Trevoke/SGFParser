# With this code, we will display info on all files within a directory:
# "Black_player-White_player.sgf"

require '../lib/sgfparser'


Dir.chdir '/home/alg/Go games/mykgsgames' # What? Sue me.

Dir.glob('*').each do |file|
  next if File.directory? file # Let's not touch directories.
  next if File.extname(file) != ".sgf" # If it's not an SGF file, let's not touch it.
  sgf = SGF::Tree.new :filename => file
  # The "root" is an empty node, always, so we can support SGF collections painlessly:
  # Whole trees simply become branches from the root.

  black = sgf.root.next[0].PB[0] rescue "Black" # Alright, so this isn't particularly elegant.
  white = sgf.root.next[0].PW[0] rescue "White" # It's a work in progress !

  # Right now, EVERY PROPERTY is saved within an array. As I detail this further,
  # And add more to it,

  puts "#{black}-#{white}.sgf"

end