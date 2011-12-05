#Thankfully, whitespace doesn't matter in SGF, unless you're inside a comment.
#This makes it possible to indent an SGF file and let it be somewhat human-readable.

require '../lib/sgf'

if ARGV.size != 2
  puts "Usage:\n sgf_indent source.sgf destination.sgf"
  exit
end

parser = SGF::Parser.new
tree = parser.parse ARGV[0]
tree.save ARGV[1]