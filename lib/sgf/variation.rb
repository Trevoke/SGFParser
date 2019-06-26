# typed: true
# frozen_string_literal: true

class SGF::Variation
  extend ::T::Sig

  attr_reader :root, :size

  def initialize
    @root = SGF::Node.new
    @size = 1
  end

  sig { params(node: SGF::Node).void }
  def append(node)
    @root.add_children node
    @size += 1
  end
end
