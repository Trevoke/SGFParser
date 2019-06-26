# typed: false
# frozen_string_literal: true

require_relative 'writer'

module SGF
  class Gametree
    include Enumerable

    extend T::Sig

    attr_reader :root

    attr_accessor :current_node

    # Takes a SGF::Node as an argument. It will be a problem if that node isn't
    # really the first node of of a game (ie: no FF property)
    sig { params(node: SGF::Node).void }
    def initialize(node)
      @root = node
      @current_node = node
    end

    # A simple way to go to the next node in the same branch of the tree
    sig { returns(Node) }
    def next_node
      @current_node = @current_node.children[0]
    end

    # Iterate through all the nodes in preorder fashion
    def each(&block)
      @root.each(&block)
    end

    sig { returns(String) }
    def inspect
      "<SGF::Gametree:#{object_id}>"
    end

    sig { returns(String) }
    def to_s
      SGF::Writer.new.stringify_tree_from @root
    end

    sig { params(range: T::Range[Integer]).returns(Gametree) }
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
