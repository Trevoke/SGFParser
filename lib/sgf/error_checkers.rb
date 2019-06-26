# typed: true
# frozen_string_literal: true

class SGF::StrictErrorChecker
  extend T::Sig

  sig { params(string: String).returns(T.any(T.noreturn, TrueClass))}
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
  extend T::Sig

  sig { params(_string: String).returns(TrueClass)}
  def check_for_errors_before_parsing(_string)
    # just look the other way
    true
  end
end
