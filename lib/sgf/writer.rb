class SGF::Writer
  def stringify_tree_from root_node
    @indentation = 0
    @sgf = ""
    write_new_branch_from root_node
  end

  # Takes a node and a filename as arguments
  def save(root_node, filename)
    #TODO - accept any I/O object
    stringify_tree_from root_node

    File.open(filename, 'w') { |f| f << @sgf }
  end

  private

  def write_tree_from node
    @sgf << "\n" << node.to_str(@indentation)
    decide_what_comes_after node
  end

  def decide_what_comes_after node
    if node.children.size == 1
      then write_tree_from node.children[0]
    else write_new_branch_from node
    end
  end

  def write_new_branch_from node
    node.each_child do |child_node|
      open_branch
      write_tree_from child_node
      close_branch
    end
  end

  def open_branch
    @sgf << "\n" << whitespace << "("
    @indentation += 2
  end

  def close_branch
    @indentation -= 2
    @indentation = (@indentation < 0) ? 0 : @indentation
    @sgf << "\n" << whitespace << ")"
  end

  def whitespace
    " " * @indentation
  end
end
