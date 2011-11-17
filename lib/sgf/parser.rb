require 'stringio'

module SGF

  #The parser returns a SGF::Tree representation of the SGF file
  #parser = SGF::Parser.new
  #tree = parser.parse sgf_in_string_form
  class Parser

    NEW_NODE = ";"
    BRANCHING = ["(", ")"]
    PROPERTY = ["[", "]"]
    NODE_DELIMITERS = [NEW_NODE].concat BRANCHING

    def initialize strict_parsing = true
      @tree = Tree.new
      @root = @tree.root
      @strict_parsing = strict_parsing
    end

    def parse sgf
      check_for_errors_before_parsing sgf if @strict_parsing
      @stream = streamable sgf
      until @stream.eof?
        char = @stream.sysread 1
        node = Node.new
        current_node.add_children node
        @current_node = node
        parse_node_data
        add_properties_to_current_node
      end
      @tree
    end

    private

    def check_for_errors_before_parsing string
      raise(SGF::MalformedDataError, "The first two characters of the string should be (;") unless string[0..1] == "(;"
    end

    def streamable sgf
      StringIO.new clean(sgf), 'r'
    end

    def clean sgf
      sgf.gsub! "\\\\n\\\\r", ''
      sgf.gsub! "\\\\r\\\\n", ''
      sgf.gsub! "\\\\r", ''
      sgf.gsub! "\\\\n", ''
      sgf
    end

    def parse_node_data
      @identities = {}
      while still_inside_node?
        parse_identity
        parse_property
        @identities[@identity] = @property
      end

    end

    def still_inside_node?
      char = next_character
      return false unless char
      @stream.pos -= 1
      return false if NODE_DELIMITERS.include? char
      true
    end

    def parse_identity
      @identity = ""
      while char = next_character and char != "["
        @identity << char
      end
    end

    def parse_property
      @property = ""
      while char = next_character and char != "]"
        @property << char
      end
    end

    def add_properties_to_current_node
      current_node.add_properties @identities
    end

    def next_character
      !@stream.eof? && @stream.sysread(1)
    end

    def current_node
      @current_node ||= @root
    end

  end

end

