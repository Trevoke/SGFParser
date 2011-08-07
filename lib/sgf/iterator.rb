require 'stringio'

module SGF

  #This is a Template class for the Indenter and the Parser
  class Iterator

    #Initialize with some object which will be returned after parsing.
    #Best if it's a node or a string.. Or I have no idea what will happen.
    #It'll probably blow up in your face.
    #I mean, let's be serious, you shouldn't be using this _anyway_.
    def initialize object
      @object = object
    end

    #It takes as argument an SGF string or filename, and will figure out what to do with the input.
    def parse sgf
      @sgf = stringified sgf
      while char = next_character
        case char
          when '(' then new_branch
          when ')' then close_branch
          when ';' then switch_to_new_node
          when '[' then add_property
          else store_character char
        end
      end
      @object
    end

    private

    def stringified sgf
      File.exist?(sgf) ? File.read(sgf) : sgf
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

  end
end