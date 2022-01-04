# frozen_string_literal: true

require_relative 'node'
require_relative 'collection'

class SGF::CollectionAssembler

  attr_reader :collection

  def initialize
    @collection = SGF::Collection.new
    @current_node = @collection.root
    @branches = []
  end

  def open_branch
    @branches.unshift @current_node
  end

  def close_branch
    @current_node = @branches.shift
  end

  def create_node_with_properties(properties)
    node = SGF::Node.new
    @current_node.add_children node
    @current_node = node
    @current_node.add_properties properties
  end

  def add_error(message)
    collection.errors << message
  end
end
