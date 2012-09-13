require 'stringio'

module SGF

  #The parser returns a SGF::Collection representation of the SGF file
  #parser = SGF::Parser.new
  #collection = parser.parse sgf_in_string_form
  class Parser

    # Fields and where they're used:
    #
    # @sgf_stream
    #   parse, parse_node_data, parse_identity, parse_comment,
    #   parse_multi_property, parse_generic_property
    #
    # @collection
    #   parse
    #
    # @current_node
    #   parse, open_branch, close_branch, create_new_node,
    #   add_properties_to_current_node
    #
    # @branches
    #   parse, open_branch, close_branch
    #
    # @node_properties
    #   parse_node_data, add_properties_to_current_node
    #
    # @identity
    #   parse_node_data, parse_identity, parse_property
    #
    # @property
    #   parse_node_data, parse_property, parse_comment,
    #   parse_multi_property, parse_generic_property, still_inside_comment

    NEW_NODE = ";"
    BRANCHING = %w{( )}
    NODE_DELIMITERS = [NEW_NODE].concat BRANCHING
    PROPERTY = %w([ ])
    LIST_IDENTITIES = %w(AW AB AE AR CR DD LB LN MA SL SQ TR VW TB TW)

    # This takes as argument an SGF and returns an SGF::Collection object
    # It accepts a local path (String), a stringified SGF (String),
    # or a file handler (File).
    # The second argument is optional, in case you don't want this to raise errors.
    # You probably shouldn't use it, but who's gonna stop you?
    def parse sgf, strict_parsing = true
      error_checker = strict_parsing ? StrictErrorChecker.new : LaxErrorChecker.new
      @sgf_stream = SgfStream.new(sgf, error_checker)
      @collection = Collection.new
      @current_node = @collection.root
      @branches = []
      until @sgf_stream.eof?
        case @sgf_stream.next_character
          when "(" then open_branch
          when ";" then
            create_new_node
            parse_node_data
            add_properties_to_current_node
          when ")" then close_branch
          else next
        end
      end
      @collection
    end

    private

    def open_branch
      @branches.unshift @current_node
    end

    def close_branch
      @current_node = @branches.shift
    end

    def create_new_node
      node = SGF::Node.new
      @current_node.add_children node
      @current_node = node
    end

    def parse_node_data
      @node_properties = {}
      while still_inside_node?
        parse_identity
        parse_property
        @node_properties[@identity] = @property
      end
    end

    def add_properties_to_current_node
      @current_node.add_properties @node_properties
    end

    def parse_identity
      @identity = ""
      while char = @sgf_stream.next_character and char != "["
        @identity << char unless char == "\n"
      end
    end

    def parse_property
      @property = ""
      case @identity.upcase
        when "C" then parse_comment
        when *LIST_IDENTITIES then parse_multi_property
        else parse_generic_property
      end
    end

    # TODO the decision to parse a comment, a multi-property, or a generic
    # property seems to be a meaningful domain concept. But right now it's
    # only represented by the three parse_ methods and the three
    # still_inside_ methods. Also, those methods share a lot of structure.
    # Let's try to push the similarities of structure into single methods,
    # so that the differences can eventually be extracted into different
    # classes.

    def parse_comment
      while char = @sgf_stream.next_character and still_inside_comment? char
        @property << char
      end
      @property.gsub! "\\]", "]"
    end

    def parse_multi_property
      while char = @sgf_stream.next_character and still_inside_multi_property? char
        @property << char
      end
      @property = @property.gsub("][", ",").split(",")
    end

    def parse_generic_property
      while char = @sgf_stream.next_character and char != "]"
        @property << char
      end
    end

    def still_inside_node?
      inside_a_node = false
      while char = @sgf_stream.next_character
        next if char[/\s/]
        inside_a_node = !NODE_DELIMITERS.include?(char)
        break
      end
      @sgf_stream.pos -= 1 if char
      inside_a_node
    end

    def still_inside_multi_property? char
      return true if char != "]"
      inside_multi_property = false
      while char = @sgf_stream.next_character
        next if char[/\s/]
        inside_multi_property = char == "["
        break
      end
      @sgf_stream.pos -= 1 if char
      inside_multi_property
    end

    def still_inside_comment? char
      char != "]" || (char == "]" && @property[-1..-1] == "\\")
    end
  end

end

class StrictErrorChecker
  def check_for_errors_before_parsing string
    unless string[/\A\s*\(\s*;/]
      msg = "The first two non-whitespace characters of the string should be (;"
      msg << " but they were #{string[0..1]} instead."
      raise(SGF::MalformedDataError, msg)
    end
  end
end

class LaxErrorChecker
  def check_for_errors_before_parsing string
    # just look the other way
  end
end

class SgfStream
  attr_reader :stream

  def initialize sgf, error_checker
    sgf = sgf.read if sgf.instance_of?(File)
    sgf = File.read(sgf) if File.exist?(sgf)
    error_checker.check_for_errors_before_parsing sgf
    @stream = StringIO.new clean(sgf), 'r'
  end

  def eof?
    @stream.eof?
  end

  def pos
    @stream.pos
  end

  def pos= new_pos
    @stream.pos = new_pos
  end

  def next_character
    !@stream.eof? && @stream.sysread(1)
  end

  private

  def clean sgf
    sgf.gsub! "\\\\n\\\\r", ''
    sgf.gsub! "\\\\r\\\\n", ''
    sgf.gsub! "\\\\r", ''
    sgf.gsub! "\\\\n", ''
    sgf
  end
end
