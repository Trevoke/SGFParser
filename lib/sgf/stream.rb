# typed: false
# frozen_string_literal: true

require 'stringio'

class SGF::Stream
  attr_reader :stream

  def initialize(sgf, error_checker)
    sgf = sgf.read if sgf.instance_of?(File)
    sgf = File.read(sgf) if File.exist?(sgf)
    error_checker.check_for_errors_before_parsing sgf
    @stream = StringIO.new clean(sgf), 'r'
  end

  def eof?
    stream.eof?
  end

  def next_character
    !stream.eof? && stream.sysread(1)
  end

  def read_token(format)
    property = ''
    while (char = next_character) && format.still_inside?(char, property, self)
      property += char
    end
    format.transform property
  end

  def peek_skipping_whitespace
    while char = next_character
      next if char[/\s/]

      break
    end
    rewind if char
    char
  end

  private

  def rewind
    stream.pos -= 1
  end

  def clean(sgf)
    sgf.gsub('\\\\n\\\\r', '')
       .gsub('\\\\r\\\\n', '')
       .gsub('\\\\r', '')
       .gsub('\\\\n', '')
  end
end
