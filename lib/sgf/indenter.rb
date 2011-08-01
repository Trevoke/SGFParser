require 'stringio'

module SGF

  # This indents an SGF file to make it more readable. It outputs to the screen
  # by default, but can be given a file as output.
  # Usage: SgfParser::Indenter.new infile, outfile
  class Indenter < Iterator

    def initialize sgf
      @new_string = ""
      @indentation = 0
      super sgf, @new_string
    end

    def new_branch
      next_line
      @indentation += 2
      indent
      @new_string << "("
    end

    def next_line
      @new_string << "\n"
    end

    def indent
      @new_string << " " * @indentation
    end

    def close_branch
      @new_string << ")"
      next_line
      @indentation -= 2
      @indentation = 0 if @indentation < 0
      indent
    end

    def switch_to_new_node
      next_line
      indent
      @new_string << ";"
    end

    #TODO Fix it more. Add _ONE_ set of indentation if there are newlines,
    #TODO Not one set for every newline.
    def add_property
      buffer = "["
      while true
        next_bit = @stream.sysread(1)
        next_bit << @stream.sysread(1) if next_bit == "\\"
        buffer << next_bit
        if next_bit == "\n"
          eat_the_newlines
          buffer << " " * @indentation
        end
        break if next_bit == "]"
      end
      buffer << "\n"
      buffer << " " * @indentation
      @new_string << buffer
    end

    def eat_the_newlines
      char = next_character until char != "\n"
      @stream.pos -= 1
    end

    def store_character char
      @new_string << char unless char == "\n"
    end

  end
end




