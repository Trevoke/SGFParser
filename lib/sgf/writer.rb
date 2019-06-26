# typed: true
# frozen_string_literal: true

class SGF::Writer
  extend ::T::Sig

  # Takes a node and a filename as arguments
  sig { params(root_node: SGF::Node, filename: String).returns(T.nilable(IO)) }
  def save(root_node, filename)
    # TODO: - accept any I/O object?
    stringify_tree_from root_node
    File.open(filename, 'w') { |f| f << @sgf }
  end

  sig { params(root_node: SGF::Node).returns(String) }
  def stringify_tree_from(root_node)
    @indentation = 0
    @sgf = ''
    write_new_branch_from root_node
    @sgf
  end

  private

  sig { params(node: SGF::Node).void }
  def write_new_branch_from(node)
    node.each_child do |child_node|
      open_branch
      write_tree_from child_node
      close_branch
    end
  end

  sig { params(node: SGF::Node).void }
  def write_tree_from(node)
    @sgf = @sgf + "\n" + node.to_s(@indentation)
    decide_what_comes_after node
  end

  sig { params(node: SGF::Node).void }
  def decide_what_comes_after(node)
    if node.children.size == 1
      write_tree_from node.children[0]
    else
      write_new_branch_from node
    end
  end

  sig { void }
  def open_branch
    @sgf += "\n#{whitespace}("
    @indentation += 2
  end

  sig { void }
  def close_branch
    @indentation -= 2
    @indentation = @indentation < 0 ? 0 : @indentation
    @sgf = @sgf + "\n" + whitespace + ')'
  end

  sig { returns(String) }
  def whitespace
    ' ' * @indentation
  end
end
