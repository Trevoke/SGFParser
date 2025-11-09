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

  def check_for_errors_after_parsing(assembler)
    unclosed_count = assembler.unclosed_branches_count
    return true if unclosed_count.zero?

    msg = "SGF file ended with #{unclosed_count} unclosed branch"
    msg += 'es' if unclosed_count > 1
    msg += '. All opening parentheses "(" must have matching closing parentheses ")".'
    raise SGF::MalformedDataError, msg
  end
end

class SGF::LaxErrorChecker
  def check_for_errors_before_parsing(_string)
    # just look the other way
    true
  end

  def check_for_errors_after_parsing(_assembler)
    # just look the other way
    true
  end
end
