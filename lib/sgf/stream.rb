# frozen_string_literal: true

require 'stringio'

class SGF::Stream

  def initialize(sgf_input, error_checker)
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

  def read_sgf_input(input)
    case
    when input.respond_to?(:read) && !input.is_a?(String)
      input.read
    when input.is_a?(String) && File.exist?(input)
      File.read(input)
    else
      input
    end
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
