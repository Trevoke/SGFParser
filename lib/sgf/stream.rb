# typed: false
# frozen_string_literal: true

require 'stringio'

class SGF::Stream
  extend ::T::Sig

  attr_reader :stream

  def initialize(sgf, error_checker)
    sgf = sgf.read if sgf.instance_of?(File)
    sgf = File.read(sgf) if File.exist?(sgf)
    error_checker.check_for_errors_before_parsing sgf
    @stream = StringIO.new clean(sgf), 'r'
  end

  sig { returns(T::Boolean) }
  def eof?
    stream.eof?
  end

  sig { returns(T.any(FalseClass, String)) }
  def next_character
    !stream.eof? && stream.sysread(1)
  end

  sig {
    params(
      format: T.any(SGF::CommentToken,
                    SGF::MultiPropertyToken,
                    SGF::GenericPropertyToken,
                    SGF::IdentityToken)
      ).returns(T.any(String, T::Array[String]))
  }
  def read_token(format)
    property = ''
    while (char = next_character) && format.still_inside?(char, property, self)
      property += char
    end
    format.transform property
  end

  sig { returns(T.any(FalseClass, String)) }
  def peek_skipping_whitespace
    while char = next_character
      next if char[/\s/]

      break
    end
    rewind if char
    char
  end

  private

  sig { void }
  def rewind
    stream.pos -= 1
  end

  sig { params(sgf: String).returns(String) }
  def clean(sgf)
    sgf.gsub('\\\\n\\\\r', '')
       .gsub('\\\\r\\\\n', '')
       .gsub('\\\\r', '')
       .gsub('\\\\n', '')
  end
end
