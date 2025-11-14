# SGFParser

[<img src="https://secure.travis-ci.org/Trevoke/SGFParser.png" />](http://travis-ci.org/Trevoke/SGFParser) [![Gitter](https://badges.gitter.im/JoinChat.svg)](https://gitter.im/Trevoke/SGFParser?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) [![Maintainability](https://api.codeclimate.com/v1/badges/cf8235d1d5ef230a4cf0/maintainability)](https://codeclimate.com/github/Trevoke/SGFParser/maintainability)

## What is this?

SGFParser is a Ruby library for reading and writing SGF (Smart Game Format) files. SGF is the standard file format for recording board games like Go, Chess, and other strategy games. If you work with Go game records, analyze games, or build tools for board game players, you need to parse SGF files—and this library makes that simple.

**Why SGFParser?** It's fast (parsing a 3MB file takes about 6 seconds), follows the FF4 standard, and provides an intuitive Ruby API for navigating game trees and accessing game data.

**Should you keep reading?** If you need to:
- Read game records from SGF files
- Extract player information, moves, or comments from games
- Navigate game variations and branches
- Create or modify SGF files programmatically

Then yes—this library will save you time.

---

## Quick Start: Your First Parse

Let's get you to a working example in under a minute.

**Install the gem:**
```bash
gem install sgf
```

**Parse your first SGF file:**
```ruby
require 'sgf'

# Parse an SGF file
collection = SGF.parse('path/to/game.sgf')

# Get the first game
game = collection.gametrees.first

# See who played
puts "Black: #{game.black_player}"
puts "White: #{game.white_player}"
```

**That's it!** You just parsed an SGF file and extracted player information. If this worked, you're ready to learn more.

---

## Learning Path: From Beginner to Expert

Now that you've seen it work, let's build your understanding step by step.

### Understanding SGF Structure

Think of an SGF file like a book. The book (Collection) contains one or more stories (Gametrees). Each story is made up of connected scenes (Nodes) that form a narrative—sometimes with alternate endings (variations).

More technically:
- **Collection**: The entire SGF file—can contain multiple games
- **Gametree** (also called `Game`): A single game record
- **Node**: One moment in the game—usually a move, setup position, or comment

The relationship: `File ↔ Collection ↔ Gametrees ↔ Nodes`

When you parse an SGF file, you get a `Collection` object. This collection has a root node that connects to all the games. For a typical SGF file with one game, you access it like this:

```ruby
collection = SGF.parse('game.sgf')
game = collection.gametrees.first
```

### Parsing Files and Strings

You've already seen file parsing. But sometimes you have SGF data as a string (maybe from a web API or database):

```ruby
sgf_string = "(;FF[4]GM[1]SZ[19];B[pd];W[dp])"
collection = SGF::Parser.new.parse(sgf_string)
```

Both approaches give you the same `Collection` object to work with.

### Accessing Game Properties

Game properties hold the data you care about: who played, when, game rules, and more. Some properties live on the game's root node (like player names), and we provide convenient shortcuts:

```ruby
game.black_player  # => "Honinbo Shusaku"
game.white_player  # => "Gennan Inseki"
game.date          # => "1846-07-21"
game.result        # => "B+2"
```

These shortcuts save you from digging into the node structure yourself. If you call a property that doesn't exist in the game type (for example, a property specific to Chess when you're parsing a Go game), you'll get a `SGF::NoIdentityError`.

**Why this matters:** The SGF standard defines different properties for different game types. This library helps you avoid mistakes by raising errors when you ask for invalid properties.

### Navigating the Game Tree

Games aren't linear—they're trees. A player might record several possible variations at a crucial point. You need to navigate this tree structure.

**Linear navigation** (following the main line):
```ruby
game.current_node  # => Root node of the game
game.next_node     # => Advances to next node and returns it
game.current_node  # => Now pointing to that next node
```

This is useful when you want to step through a game move by move, maybe displaying it to a user or analyzing the main line.

**Understanding your position** in the tree:
```ruby
node.depth  # => How far from the root (0 = root)
```

When you're navigating a complex game with many variations, `depth` helps you know where you are.

**Iterating through all nodes:**
```ruby
game.each do |node|
  puts "Node at depth #{node.depth} has #{node.properties.count} properties"
end
```

This gives you every node in the tree using preorder traversal (parents before children). Both `Collection` and `Node` objects also support `each`, so you can iterate from any starting point:

```ruby
collection.each { |node| ... }  # All nodes in all games
game.each { |node| ... }        # All nodes in one game
some_node.each { |node| ... }   # All nodes from this point down
```

**Why preorder traversal?** It mirrors how you'd read the game naturally: position first, then explore variations. You usually won't need to think about this, but it helps explain the order you see.

### Saving and Writing SGF Files

Once you've modified game data or created new games, you need to save them:

**Save a collection to a file:**
```ruby
collection.save('output.sgf')
```

**Write from any node:**
```ruby
# Save just a subtree starting from a specific node
SGF::Writer.new.save(node, 'variation.sgf')

# Or get the SGF as a string
sgf_string = SGF::Writer.new.stringify_tree_from(node)
```

**Quick conversion to SGF strings:**
```ruby
collection.to_s  # Entire collection
game.to_s        # Single game
node.to_s        # Subtree from node
```

**Important:** When writing SGF files, the library automatically escapes closing brackets (`]`) in comments as `\]`. This is required by the SGF standard. When parsing, the library expects this escaping—files that don't follow this rule will cause parsing errors.

**Why the escaping matters:** In SGF, property values are enclosed in brackets like `C[This is a comment]`. If your comment contains `]`, the parser thinks the value has ended. Escaping prevents this.

---

## Reference

This section is for quick lookups once you understand the system.

### Version Support
- **SGF Format:** FF4 (may work with earlier versions, untested)
- **Ruby:** >= 2.1

### Core API

**Parsing:**
```ruby
SGF.parse(filename)              # Parse file, returns Collection
SGF::Parser.new.parse(string)    # Parse string, returns Collection
```

**Navigation:**
```ruby
collection.gametrees             # Array of all games
game.root                        # Root node of game
game.current_node                # Current position (starts at root)
game.next_node                   # Move to next and return it
node.depth                       # Distance from root
node.children                    # Child nodes
node.parent                      # Parent node
```

**Properties:**
```ruby
game.black_player                # Shortcut to root property
game.white_player                # Shortcut to root property
game.date                        # Shortcut to root property
game.result                      # Shortcut to root property
node.properties                  # Hash of all properties
```

**Iteration:**
```ruby
collection.each { |node| ... }   # All nodes in all games
game.each { |node| ... }         # All nodes in game
node.each { |node| ... }         # All nodes from this point
```

**Writing:**
```ruby
collection.save(filename)        # Save to file
collection.to_s                  # Convert to SGF string
game.to_s                        # Game as SGF string
node.to_s                        # Subtree as SGF string
SGF::Writer.new.save(node, file) # Save subtree to file
SGF::Writer.new.stringify_tree_from(node)  # Subtree as string
```

### Critical Warnings

**Bracket escaping:** Any closing bracket `]` inside a property value (especially comments) MUST be escaped as `\]`. The library handles this automatically when saving, but will fail when parsing non-compliant files.

### Performance Note

On a typical desktop, parsing Kogo's Joseki Dictionary (a 3MB file) takes about 6 seconds. Since most SGF files are around 10KB, parsing is typically very fast.

---

## Contributing

Using this gem? Have feedback? We'd love to hear from you:
- Is there functionality you wish it had?
- Is something hard to do?
- Does the documentation need clarification?

Join the conversation on [Gitter](https://gitter.im/Trevoke/SGFParser) or open an issue on GitHub.

---

## Publishing Note

The branch used for publishing the gem is `congruence`—chosen because it has strong connotations for proper integration. All changes brought into this branch are congruent.
