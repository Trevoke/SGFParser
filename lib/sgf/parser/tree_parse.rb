module SgfParser
  class Tree

    private

    # This function parses a SGF string into a linked list, or tree.
    def parse
      @sgf.gsub! "\\\\n\\\\r", ""
      @sgf.gsub! "\\\\r\\\\n", ""
      @sgf.gsub! "\\\\r", ""
      @sgf.gsub! "\\\\n", ""
      #@sgf.gsub! "\n", ""
      branches = [] # This stores where new branches are open
      current_node = @root # Let's start at the beginning, shall we?
      identprop = false # We are not in the middle of an identprop value.
                        # An identprop is an identity property - a value.
      content = Hash.new # Hash holding all the properties
      param, property = "", "" # Variables holding the idents and props
      end_of_a_series = false # To keep track of params with multiple properties

      sgf_array = @sgf.split(//)
      iterator = 0
      array_length = sgf_array.size

      while iterator < array_length
        char = sgf_array[iterator]
        case char
=begin
Basically, if we're inside an identprop, it's a normal character (or a closing
character).
If we're not, it's either a property or a special SGF character so we have
to handle that properly.
=end
          when '(' # Opening a new branch
            if identprop
              property << char
            else
              branches.unshift current_node
            end
          when ')' # Closing a branch
            if identprop
              property << char
            else
              current_node = branches.shift
              param, property = "", ""
              content.clear              
            end
          when ';' # Opening a new node
            if identprop
              property << char
            else
              # Make the current node the old node, make new node, store data
                parent = current_node
                current_node = Node.new :parent => parent
                parent.add_properties content
                parent.add_children current_node
                param, property = "", ""
                content.clear
            end
          when '[' # Open identprop?
            if identprop
              property << char
            else # If we're not inside an identprop, then now we are.
              identprop = true
              end_of_a_series = false
            end
          when ']' # Close identprop
# Cleverness : checking for this first, then for the backslash.
# This means that if we encounter this, it must be closing an identprop.
# Because the "\\" code handles the logic to see if we're inside an identprop,
# And for skipping the bracket if necessary.            
            end_of_a_series = true # Maybe end of a series of identprop.
            identprop = false # That's our cue to close an identprop.
            content[param] = property
            property = ""
          when "\\"
            # If we're inside a comment, then maybe we're about to escape a ].
            # This is the whole reason we need this ugly loop.
            if identprop
              # If the next character is a closing bracket, then it's just
              # escaped and the identprop continues.
              if sgf_array[iterator + 1] == "]"
                property << "]"
                # On the next pass through, we will skip that bracket.
                iterator += 1
              else
                property << "\\"
              end
            else
              #This should never happen - a backslash outside an identprop ?!
              #But let's not have it be told that I'm not prepared.
              param << "\\"
            end
          when "\n"
            property << "\n" if identprop

          else
            # Well, I guess it's "just" a character after all.
            if end_of_a_series
              end_of_a_series = false
              param, property = "", ""
            end
            identprop ? (property << char) : param << char
        end
        iterator += 1
      end

    end

  end
end