module SGF
  class MalformedDataError < StandardError
    # error raised by parser
  end
  class FormatNotSpecifiedWarning < StandardError
    # Warning if FF is not in first node
  end
end