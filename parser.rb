require 'pp'
require 'tree'
# This is only guaranteed to work for the game of Go.

# ; starts a new node
# ( starts a new tree (more than one branch)
# W[] => label, then property of label



a = SGFTree.new 'dosak25.sgf'


puts "\nMY OUTPUT BEGINS!\n"

pp a.root.next[0].properties
pp a.root.next[0].next[0].next[0].properties

puts "\nMY OUTPUT ENDS!\n"

a = SGFTree.new 'ff4_ex.sgf'

puts "\nMY OUTPUT BEGINS!\n"

pp a.root.next[0].properties
pp a.root.next[0].next[0].properties

puts "\nMY OUTPUT ENDS!\n"

a = SGFTree.new '1.sgf'

puts "\nMY OUTPUT BEGINS!\n"

pp a.root.next[0].properties
pp a.root.next[0].next[0].properties

puts "\nMY OUTPUT ENDS!\n"