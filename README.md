# SGFParser
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/Trevoke/SGFParser?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Build status {<img src="https://secure.travis-ci.org/Trevoke/SGFParser.png" />}[http://travis-ci.org/Trevoke/SGFParser]

# Intro
I'm hoping that this is and remains the fastest SGF parser in Ruby. On my desktop, loading the SGF library and parsing Kogo's Joseki dictionary takes a little under six seconds. It's a 3MB file and the average SGF is maybe 10k, so on average it's rather snappy.

Are you using this gem? Is there functionality you wish it had? Is something hard to do? Does the documentation not make sense, and you know how to make it more helpful? Let me know and I'll make it possible, or easier!

# Supported versions
SGF: FF4 - may support earlier ones as well, but untested.
Ruby: >=1.9


# Intro to SGF
According to the standard, An SGF file holds a `Collection` of one or more `Gametree` objects. Each of those is made of a tree of `Node` objects.

In other words: FILE (1 ↔ ∞) Collection (1 ↔ ∞) Gametree (1 ↔ ∞) Node

In this implementation, when you parse a file, you get a `Collection` back. This object has a root `Node` used as the top-level node for all gametrees. The children of that node are the root nodes of the actual games.

Assuming a common SGF file with a single game, you could get to the game by doing this:

```ruby
SGF.parse(file).gametrees.first # => <SGF::Game:70180384181460>
```

Some properties belong on the root node of a game only, such as the identity of the players. For convenience, some human-readable methods are defined on the gametree object itself to reach this information, for instance

```ruby
gametree.black_player # => "tartrate"
```

Calling a property that is not defined in the current tree will result in an error. For instance, a property that does not exist in the game of Go:

```ruby
gametree.black_octisquares # => SGF::NoIdentityError
```

Since a game is a tree (each node can be the source of many variations), a convenience method is defined to help you traverse the main branch one node at a time.

```ruby
gametree.current_node # => starts as root node, e.g. #<SGF::Node:70180384857820, Has a parent, 1 Children, 16 Properties>
gametree.next_node    # => #<SGF::Node:70180384839420, Has a parent, 1 Children, 4 Properties>
gametree.current_node # => #<SGF::Node:70180384839420, Has a parent, 1 Children, 4 Properties>
```

Since it's easy to get lost when you're looking at things one node at a time (or because sometimes you don't want to iterate with an index), we also provide a convenience `depth` method on a given node to tell you how far down the tree you are.

And since this is Ruby, all of the objects (`Collection`, `Gametree` and `Node`) provide iteration through `each`. Note that in this example, we are using a gametree, and iteration on a gametree starts from the gametree's root, so the depth is 1. Iteration on a collection starts from the collection's root, and that node's depth would be 0. Iteration on any node starts from that node and goes through all its children.

NOTE: iteration is done as preorder tree traversal. You shouldn't have to care about this, but you might.

```ruby
gametree.each do |node|
  puts "Node at depth #{node.depth} has #{node.properties.count} properties"
end
=begin
Node at depth 1 has 16 properties
Node at depth 2 has 4 properties
Node at depth 3 has 3 properties
Node at depth 4 has 4 properties
Node at depth 5 has 3 properties
Node at depth 6 has 3 properties
Node at depth 7 has 3 properties
Node at depth 8 has 4 properties
... And so on
=end
```

# SGF Parsing warning (À bon entendeur…)
WARNING: An implementation requirement is to make sure any closing bracket ']' inside a comment is escaped: '\\]'. If this is not done, you will be one sad panda! This library will do this for you upon saving, but will most likely die horribly when parsing anything which does not follow this rule.
