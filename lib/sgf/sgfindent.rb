def tabulate indent
  indent.times { |a| print " " }
end

sgf = ""
File.open('../features/samples/redrose-tartrate.sgf') { |f| sgf = f.read }

sgf.gsub! "\\\\n\\\\r", ""
sgf.gsub! "\\\\r\\\\n", ""
sgf.gsub! "\\\\r", ""
sgf.gsub! "\\\\n", ""
#@sgf.gsub! "\n", ""

identprop = false # We are not in the middle of an identprop value.
# An identprop is an identity property - a value.

sgf_array = sgf.split(//)
iterator = 0
array_length = sgf_array.size
indent = 0
previous_character = nil

while iterator < array_length - 1
  char = sgf_array[iterator]

  case char
    when '(' # Opening a new branch
      if !identprop
        puts ""
        indent += 2
        tabulate indent
      end
      print char

    when ')' # Closing a branch
      print char
      if !identprop
        puts ""
        indent -= 2
        tabulate indent
      end

    when ';' # Opening a new node
      if !identprop
        puts ""
        tabulate indent
      end
      print char

    when '[' # Open comment?
      if !identprop #If we're not inside a comment, then now we are.
        identprop = true
        end_of_a_series = false
      end
      print char

    when ']' # Close comment
      end_of_a_series = true # Maybe end of a series of comments.
      identprop = false # That's our cue to close a comment.
      print char

    when "\\" # If we're inside a comment, then maybe we're about to escape a ].
      # This is the whole reason we need this ugly charade of a loop.
      if identprop
        if sgf_array[iterator + 1] == "]"
          print "\\]"
          iterator += 1
        else
          print "\\"
        end
      else
        #This should never happen - a backslash outside a comment ?!
        #But let's not have it be told that I'm not prepared.
        print "\\"
      end

    when "\n"
      print "\n"
      tabulate indent

    else
      # Well, I guess it's "just" a character after all.
      if end_of_a_series
        end_of_a_series = false
      end
      print char
  end

  iterator += 1
end