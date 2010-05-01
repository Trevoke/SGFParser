require 'stringio'

module SgfParser

  # This indents an SGF file to make it more readable. It outputs to the screen
  # by default, but can be given a file as output.
  # Usage: SgfParser::Indenter.new infile, outfile
  class Indenter

    def initialize file, out=$stdout
      @stream = load_file_to_stream(file)
      @new_string = ""
      @indentation = 0
      @out = (out == $stdout) ? $stdout : File.open(out, 'w')
      parse
    end

    def next_character
      !@stream.eof? && @stream.sysread(1)
    end

    def parse
      while char = next_character
        case char
          when '(' then open_branch
          when ')' then close_branch
          when ';' then new_node
          when '[' then add_property
          else add_identity(char)
        end
      end

      @out << @new_string
      @out.close unless @out == $stdout
      #if out == $stdout
      #  $stdout << @new_string
      #else
      #  File.open(out, 'w') { |file| file << @new_string }
      #end      
    end

    def open_branch
      next_line
      @indentation += 2
      @new_string << " " * @indentation
      @new_string << "("
    end

    def close_branch
      @new_string << ")"
      next_line
      @indentation -= 2
      @indentation = 0 if @indentation < 0
      @new_string << " " * @indentation
    end

    def new_node
      next_line
      @new_string << " " * @indentation
      @new_string << ";"
    end

    def next_line
      @new_string << "\n"
    end

    #TODO Fix it more. Add _ONE_ set of indentation if there are newlines,
    #TODO Not one set for every newline.
    def add_property
      buffer = "["
      while true
        next_bit = @stream.sysread(1)
        next_bit << @stream.sysread(1) if next_bit == "\\"
        buffer << next_bit
        buffer << " " * @indentation if next_bit == "\n"
        break if next_bit == "]"
      end
      buffer << "\n"
      buffer << " " * @indentation
      @new_string << buffer
    end

    def add_identity(char)
      @new_string << char unless char == "\n"
    end

    private

    def load_file_to_stream(file)
      sgf = ""
      File.open(file) { |f| sgf = f.read }
      clean_string(sgf)
      return StringIO.new(sgf, 'r')
    end

    def clean_string(sgf)
      sgf.gsub! "\\\\n\\\\r", ""
      sgf.gsub! "\\\\r\\\\n", ""
      sgf.gsub! "\\\\r", ""
      sgf.gsub! "\\\\n", ""
    end    

  end
end




