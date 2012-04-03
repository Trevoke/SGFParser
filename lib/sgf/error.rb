module SGF
  class MalformedDataError < StandardError
    # error raised by parser
  end
  class FormatNotSpecifiedWarning < StandardError
    # Warning if FF is not in first node
  end

  class NoIdentityError < StandardError
    # Error if the user tries to read an identity that doesn't exist
  end
end
