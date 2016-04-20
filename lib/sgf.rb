$: << File.dirname(__FILE__)

require 'sgf/error'
require 'sgf/version'
require 'sgf/properties'
require 'sgf/variation'
require 'sgf/node'
require 'sgf/collection'
require 'sgf/parser'
require 'sgf/gametree'
require 'sgf/writer'

module SGF
  def self.parse(filename)
    SGF::Parser.new.parse File.read(filename)
  end
end