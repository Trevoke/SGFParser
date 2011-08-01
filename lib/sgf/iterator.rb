require 'stringio'

module SGF
  class Iterator
    def initialize object
      @object = object
    end

    def stringified sgf
      File.exist?(sgf) ? File.read(sgf) : sgf
    end

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