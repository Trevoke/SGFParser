# frozen_string_literal: true

require 'stringio'

class SGF::Stream

  def initialize(sgf_input, error_checker)
    validate_input(sgf_input)
    @sgf_input = sgf_input
    @error_checker = error_checker
    @stream = nil
  end

  def stream
    @stream ||= begin
      sgf_content = read_sgf_input(@sgf_input)
      @error_checker.check_for_errors_before_parsing sgf_content
      StringIO.new clean(sgf_content), 'r'
    end
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

  def validate_input(input)
    return if input.is_a?(String)
    return if input.respond_to?(:read)

    raise ArgumentError, "SGF input must be a String or respond to :read, got #{input.class}"
  end

  def read_sgf_input(input)
    return input.read if input.respond_to?(:read)
    return File.read(input) if File.exist?(input)
    input
  end

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
