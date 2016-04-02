# SGFParser
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/Trevoke/SGFParser?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Build status {<img src="https://secure.travis-ci.org/Trevoke/SGFParser.png" />}[http://travis-ci.org/Trevoke/SGFParser]

# Intro
I'm honestly hoping that this is and remains the fastest SGF parser in Ruby. On my desktop, loading the SGF library and parsing Kogo's Joseki dictionary takes a little under six seconds.

Documentation available at the Github wiki: https://github.com/Trevoke/SGFParser/wiki


Are you using this gem? Is there functionality you wish it had? Is something hard to do? Does the documentation not make sense, and you know how to make it more helpful? Let me know and I'll make it possible, or easier!

# Supported versions
SGF: FF4 - may support earlier ones as well, but untested.
Ruby: >=1.9


## Desired behavior (aka TODO for v3):

```ruby
record = SGF.parse file/URI/IO
record.class   #=> SGF::Record
record.pw      #=> White Player
record.pb      #=> Black Player
record.games   #=> [ SGF::Game, ... ]
main_branch = game_record.main_branch
```

# SGF Parsing warning
WARNING: An implementation requirement is to make sure any closing bracket ']' inside a comment is escaped: '\\]'. If this is not done, you will be one sad panda! This library will do this for you upon saving, but will most likely die horribly when parsing anything which does not follow this rule.
