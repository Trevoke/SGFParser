# typed: strong
# frozen_string_literal: true

require 'sorbet-runtime'

module SGF
  extend T::Sig

  VERSION = T.let('3.0.2', String)
end
