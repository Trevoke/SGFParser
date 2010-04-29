#TODO: Implement with StringIO. (require 'stringio')

require 'stringio'

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

      @stream = StringIO.new @sgf, 'r'
      @identity, @property, @content = "", "", {}

      until @stream.eof?
        char = @stream.sysread(1)

        case char
          when '('
            branches.unshift current_node
          when ')'
            current_node = branches.shift
            clear_temporary_data
          when ';'
            parent = current_node
            current_node = Node.new :parent => parent
            parent.add_properties @content
            parent.add_children current_node
            clear_temporary_data
          when '['
            get_property
            @content[@identity] ||= ""
            @content[@identity] << @property
            @identity = ""          
          else
            @identity << char unless char == "\n"
        end
      end
    end

    def get_property
      @property = ""
      while true
        parsed_bit = @stream.sysread(1)
        break if parsed_bit == "]"
        parsed_bit << @stream.sysread(1) if parsed_bit == "\\"
        parsed_bit = "]" if parsed_bit == "\\]"
        @property << parsed_bit
      end
    end

    def clear_temporary_data
      @content.clear
      @identity, @property = "", ""
    end

  end
end