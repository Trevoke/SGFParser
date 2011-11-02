require 'stringio'

module SGF

  class MalformedDataError < StandardError; end
  
  #Welcome to the magical parser!
  #This will give you a Tree object to manipulate as you see fit.
  #parser = SGF::Parser.new
  #tree = parser.parse sgf_in_string_form
  class Parser

    def initialize
      @tree = Tree.new
      @root = @tree.root
    end

    def parse sgf
      @stream = streamable sgf
      @tree
    end

    private

    def streamable sgf
      StringIO.new clean(sgf), 'r'
    end

    def next_character
      !@stream.eof? && @stream.sysread(1)
    end

    def clean sgf
      sgf.gsub! "\\\\n\\\\r", ''
      sgf.gsub! "\\\\r\\\\n", ''
      sgf.gsub! "\\\\r",      ''
      sgf.gsub! "\\\\n",      ''
      sgf
    end

  end

end

