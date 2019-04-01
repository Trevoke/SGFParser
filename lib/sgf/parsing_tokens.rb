# frozen_string_literal: true
module SGF
  class IdentityToken
    def still_inside?(char, _token_so_far, _sgf_stream)
      char != '['
    end

    def transform(token)
      token.delete "\n"
    end
  end

  class CommentToken
    def still_inside?(char, token_so_far, _sgf_stream)
      char != ']' || (char == ']' && token_so_far[-1..-1] == '\\')
    end

    def transform(token)
      token.gsub '\\]', ']'
    end
  end

  class MultiPropertyToken
    def still_inside?(char, _token_so_far, sgf_stream)
      return true if char != ']'

      sgf_stream.peek_skipping_whitespace == '['
    end

    def transform(token)
      token.gsub('][', ',').split(',')
    end
  end

  class GenericPropertyToken
    def still_inside?(char, _token_so_far, _sgf_stream)
      char != ']'
    end

    def transform(token)
      token
    end
  end
end