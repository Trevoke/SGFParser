require 'stringio'

module SGF
  #Welcome to the magical parser!
  #This will give you a Tree object to manipulate as you see fit.
  #parser = SGF::Parser.new
  #tree = parser.parse(string_or_filename)
  class Parser < Iterator

    def initialize
      tree = Tree.new
      @root = tree.root
      super tree
    end

    private

    def new_branch
      @branches ||= []
      @branches.unshift @current_node
    end

    def close_branch
      @current_node = @branches.shift
      clear_temporary_data
    end

    def switch_to_new_node
      parent = current_node
      @current_node = Node.new :parent => parent
      parent.add_properties content
      parent.add_children @current_node
      clear_temporary_data
    end

    def add_property
      content[identity] ||= ""
      content[identity] << get_property
      @identity = ""
    end

    def get_property
      buffer = ""
      while char = next_character
        case char
          when "]" then break unless multiple_properties?
          when "\\" then
            char << next_character
            char = "]" if char == "\\]"
        end

        buffer << char
      end
      "[#{buffer}]"
    end

    def multiple_properties?
      multiple_properties = false
      if char = next_character
        char = next_character if char == "\n"
        if char == "["
          multiple_properties = true
        end
        @stream.pos -= 1
        multiple_properties
      end
    end

    def store_character(char)
      identity << char unless char == "\n"
    end

    def clear_temporary_data
      @content.clear
      @identity = ""
    end

    def current_node
      @current_node ||= @root
    end

    def content
      @content ||= {}
    end

    def identity
      @identity ||= ""      
    end

  end
end

