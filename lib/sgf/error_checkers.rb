# frozen_string_literal: true

class SGF::StrictErrorChecker
  def check_for_errors_before_parsing(string)
    if string[/\A\s*\(\s*;/]
      return true
    else
      msg = 'The first two non-whitespace characters of the string should be (;'
      msg += " but they were #{string[0..1]} instead."
      raise(SGF::MalformedDataError, msg)
    end
  end
end

class SGF::LaxErrorChecker
  def check_for_errors_before_parsing(_string)
    # just look the other way
    true
  end
end
