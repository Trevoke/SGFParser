module SGF
  class Writer

    def initialize(root, filename)
      @root = root
      @filename = filename
      @indentation = 0
    end

    def save
      @indentation += 2
      @sgf = ""
      @root.children.each do |node|
        @sgf << "("
        write_tree_from node
      end
      close_branch
      File.open(@filename, 'w') { |f| f << @sgf }
    end

    # Creates a stringified SGF tree from the given node.
    def write_tree_from node
      @sgf << "\n" << node.to_s(@indentation)
      decide_what_comes_after node
    end

    def decide_what_comes_after node
      case node.children.size
        #when 0 then
        #  close_branch
        when 1 then write_tree_from node.children[0]
        else
          node.each_child do |child_node|
            open_branch
            write_tree_from child_node
            close_branch
          end
      end
    end

    private

    def whitespace
      " " * @indentation
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
  end
end