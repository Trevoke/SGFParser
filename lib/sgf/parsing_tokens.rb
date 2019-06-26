# typed: strong
# frozen_string_literal: true

class SGF::IdentityToken
  extend ::T::Sig
  sig {
    params(char: String, _token_so_far: String, _sgf_stream: SGF::Stream)
      .returns(T::Boolean)
  }
  def still_inside?(char, _token_so_far, _sgf_stream)
    char != '['
  end

  sig { params(token: String).returns(String) }
  def transform(token)
    token.delete "\n"
  end
end

class SGF::CommentToken
  extend ::T::Sig
  sig {
    params(char: String, token_so_far: String, _sgf_stream: SGF::Stream)
      .returns(T::Boolean)
  }
  def still_inside?(char, token_so_far, _sgf_stream)
    char != ']' || (char == ']' && token_so_far[-1..-1] == '\\')
  end

  sig { params(token: String).returns(String) }
  def transform(token)
    token.gsub '\\]', ']'
  end
end

class SGF::MultiPropertyToken
  extend ::T::Sig
  sig {
    params(char: String, _token_so_far: String, sgf_stream: SGF::Stream)
      .returns(T::Boolean)
  }
  def still_inside?(char, _token_so_far, sgf_stream)
    return true if char != ']'

    sgf_stream.peek_skipping_whitespace == '['
  end

  sig { params(token: String).returns(T::Array[String]) }
  def transform(token)
    token.gsub('][', ',').split(',')
  end
end

class SGF::GenericPropertyToken
  extend ::T::Sig
  sig {
    params(char: String, _token_so_far: String, _sgf_stream: SGF::Stream)
      .returns(T::Boolean)
  }
  def still_inside?(char, _token_so_far, _sgf_stream)
    char != ']'
  end

  sig { params(token: String).returns(String) }
  def transform(token)
    token
  end
end
