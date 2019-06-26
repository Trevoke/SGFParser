# typed: true
# frozen_string_literal: true

require_relative 'collection_assembler'
require_relative 'parsing_tokens'
require_relative 'error_checkers'
require_relative 'stream'

# The parser returns a SGF::Collection representation of the SGF file
# parser = SGF::Parser.new
# collection = parser.parse sgf_in_string_form
class SGF::Parser
  extend ::T::Sig

  NEW_NODE = ';'
  BRANCHING = %w[( )].freeze
  END_OF_FILE = false
  NODE_DELIMITERS = [NEW_NODE].concat(BRANCHING).concat([END_OF_FILE])
  PROPERTY = %w([ ]).freeze
  LIST_IDENTITIES = %w[AW AB AE AR CR DD LB LN MA SL SQ TR VW TB TW].freeze
  private_constant :NEW_NODE, :BRANCHING, :END_OF_FILE,
                   :NODE_DELIMITERS, :PROPERTY, :LIST_IDENTITIES

  # This takes as argument an SGF and returns an SGF::Collection object
  # It accepts a local path (String), a stringified SGF (String),
  # or a file handler (File).
  # The second argument is optional, in case you don't want this to raise errors.
  # You probably shouldn't use it, but who's gonna stop you?
  sig {
    params(
      sgf: T.any(String, File),
      strict_parsing: T::Boolean
    ).returns(SGF::Collection)
  }
  def parse(sgf, strict_parsing = true)
    error_checker = strict_parsing ? SGF::StrictErrorChecker.new : SGF::LaxErrorChecker.new
    @sgf_stream = SGF::Stream.new(sgf, error_checker)
    @assembler = SGF::CollectionAssembler.new
    until @sgf_stream.eof?
      case @sgf_stream.next_character
      when '(' then @assembler.open_branch
      when ';' then
        parse_node_data
        @assembler.create_node_with_properties @node_properties
      when ')' then @assembler.close_branch
      else next
      end
    end
    @assembler.collection
  end

  private

  sig { void }
  def parse_node_data
    @node_properties = {}
    while still_inside_node?
      identity = @sgf_stream.read_token SGF::IdentityToken.new
      property_format = property_token_type identity
      property = @sgf_stream.read_token property_format
      if @node_properties[identity]
        @node_properties[identity].concat property
        @assembler.add_error "Multiple #{identity} identities are present in a single node. A property should only exist once per node."
      else
        @node_properties[identity] = property
      end
    end
  end

  sig { returns(T::Boolean) }
  def still_inside_node?
    !NODE_DELIMITERS.include?(@sgf_stream.peek_skipping_whitespace)
  end

  sig {
    params(identity: String)
      .returns(T.any(SGF::CommentToken, SGF::MultiPropertyToken, SGF::GenericPropertyToken))
  }
  def property_token_type(identity)
    case identity.upcase
    when 'C' then SGF::CommentToken.new
    when *LIST_IDENTITIES then SGF::MultiPropertyToken.new
    else SGF::GenericPropertyToken.new
    end
  end
end
