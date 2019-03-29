# frozen_string_literal: true

class SGF::Variation
  attr_reader :root
  def initialize
    @root = SGF::Node.new
    @size = 1
  end

  def append(node)
    @root.add_children node
    @size += 1
  end

  attr_reader :size
end
