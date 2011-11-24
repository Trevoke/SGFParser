#Thankfully, whitespace doesn't matter in SGF, unless you're inside a comment.
#This makes it possible to indent an SGF file and let it be somewhat human-readable.

require '../lib/sgf'

indenter = SGF::Indenter.new
new_sgf = indenter.parse ARGV[0]
File.open(ARGV[1], 'w') { |f| new_sgf }