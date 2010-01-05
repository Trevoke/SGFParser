module SgfParser

  # This indents an SGF file to make it more readable. It outputs to the screen
  # by default, but can be given a file as output.
  # Usage: SgfParser::Indenter.new infile, outfile
  class Indenter

    def initialize file, out=$stdout
      sgf = ""
      File.open(file) { |f| sgf = f.read }
      @new_string = ""
      sgf.gsub! "\\\\n\\\\r", ""
      sgf.gsub! "\\\\r\\\\n", ""
      sgf.gsub! "\\\\r", ""
      sgf.gsub! "\\\\n", ""
      #sgf.gsub! "\n", ""

      end_of_a_series = false
      identprop = false # We are not in the middle of an identprop value.
      # An identprop is an identity property - a value.

      sgf_array = sgf.split(//)
      iterator = 0
      array_length = sgf_array.size
      indent = 0

      while iterator < array_length - 1
        char = sgf_array[iterator]

        case char
          when '(' # Opening a new branch
            if !identprop
              @new_string << "\n"
              indent += 2
              #tabulate indent
              @new_string << " " * indent
            end
            @new_string << char

          when ')' # Closing a branch
            @new_string << char
            if !identprop
              @new_string << "\n"
              indent -= 2
              @new_string << " " * indent
              #tabulate indent
            end

          when ';' # Opening a new node
            if !identprop
              @new_string << "\n"
              @new_string << " " * indent
              #tabulate indent
            end
            @new_string << char

          when '[' # Open comment?
            if !identprop #If we're not inside a comment, then now we are.
              identprop = true
              end_of_a_series = false
            end
            @new_string << char

          when ']' # Close comment
            end_of_a_series = true # Maybe end of a series of comments.
            identprop = false # That's our cue to close a comment.
            @new_string << char

          when "\\" # If we're inside a comment, then maybe we're about to escape a ].
            # This is the whole reason we need this ugly charade of a loop.
            if identprop
              if sgf_array[iterator + 1] == "]"
                @new_string << "\\]"
                iterator += 1
              else
                @new_string << "\\"
              end
            else
              #This should never happen - a backslash outside a comment ?!
              #But let's not have it be told that I'm not prepared.
              @new_string << "\\"
            end

          when "\n"
            @new_string << "\n"
            @new_string << " " * indent
            #tabulate indent

          else
            # Well, I guess it's "just" a character after all.
            if end_of_a_series
              end_of_a_series = false
            end
            @new_string << char
        end

        iterator += 1
      end

      if out == $stdout
        $stdout << @new_string
      else
        File.open(out, 'w') { |file| file << @new_string }
      end
      
    end

    private

    def tabulate indent
      indent.times { print " " }
    end
  end
end




