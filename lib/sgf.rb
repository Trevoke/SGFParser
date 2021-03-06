# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'

module SGF
  extend T::Sig

  class FileDoesNotExistError < StandardError; end

  sig {
    params(filename: String)
      .returns(T.any(T.noreturn, SGF::Collection))
  }
  def self.parse(filename)
    SGF::Parser.new.parse File.read(filename)
  rescue Errno::ENOENT
    raise FileDoesNotExistError
  end
end

require_relative 'sgf/error'
require_relative 'sgf/version'
require_relative 'sgf/properties'
require_relative 'sgf/variation'
require_relative 'sgf/node'
require_relative 'sgf/collection'
require_relative 'sgf/parser'
require_relative 'sgf/gametree'
require_relative 'sgf/writer'
require_relative 'sgf/gtp_writer'
