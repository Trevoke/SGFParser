# frozen_string_literal: true

require_relative 'writer'

module SGF
  class Gametree
    include Enumerable

    attr_reader :root
    attr_accessor :current_node

    # Takes a SGF::Node as an argument. It will be a problem if that node isn't
    # really the first node of of a game (ie: no FF property)
    def initialize(node)
      @root = node
      @current_node = node
    end

    # A simple way to go to the next node in the same branch of the tree
    def next_node
      @current_node = @current_node.children[0]
    end

    # Iterate through all the nodes in preorder fashion
    def each(&block)
      @root.each(&block)
      self
    end

    def inspect
      "<SGF::Gametree:#{object_id}>"
    end

    def to_s
      SGF::Writer.new.stringify_tree_from @root
    end

    def slice(range)
      new_root = nil
      each do |node|
        if node.depth == range.begin
          new_root = node.dup
          break
        end
      end

      new_root ||= @root.dup
      new_root.depth = 0
      new_root.parent = nil
      SGF::Gametree.new new_root
    end
  end
end
