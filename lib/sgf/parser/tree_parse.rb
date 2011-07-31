require 'stringio'

module SGF
  class Tree

    def parse
      while char = next_character
        case char
          when '(' then store_branch
          when ')' then fetch_branch
          when ';' then store_node_and_create_new_node
          when '[' then get_and_store_property
          else store_character(char)
        end
      end
    end

    def next_character
      character_available? && @stream.sysread(1)
    end

    def character_available?
      @stream ||= StringIO.new clean_string, 'r'
      !@stream.eof?
    end

    def clean_string
      @sgf.gsub! "\\\\n\\\\r", ""
      @sgf.gsub! "\\\\r\\\\n", ""
      @sgf.gsub! "\\\\r", ""
      @sgf.gsub! "\\\\n", ""
      @sgf
    end    

    def store_branch
      @branches ||= []
      @branches.unshift @current_node
    end

    def current_node
      @current_node ||= @root
    end    

    def fetch_branch
      @current_node = @branches.shift
      clear_temporary_data
    end

    def store_node_and_create_new_node
      parent = current_node
      @current_node = Node.new :parent => parent
      parent.add_properties content
      parent.add_children @current_node
      clear_temporary_data
    end

    def get_and_store_property
      @content[@identity] ||= ""
      @content[@identity] << get_property
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
      @identity << char unless char == "\n"
    end

    def clear_temporary_data
      @content.clear
      @identity = ""
    end

    def content
      @content ||= {}
    end

    def identity
      @identity ||= ""      
    end

  end
end

