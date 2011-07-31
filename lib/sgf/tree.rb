module SGF

  class Tree
    include Enumerable

    attr_accessor :root

    def initialize sgf
      @root = Node.new
      @sgf = sgf
    end

    def each order=:preorder, &block
      # I know, I know. SGF is only preorder. Well, it's implemented, ain't it?
      # Stop complaining.
      case order
        when :preorder
          preorder @root, &block
      end
    end

    # Compares a tree to another tree, node by node.
    # Nodes must be the same (same properties, parents and children).
    def == other_tree
      one = []
      two = []
      each { |node| one << node }
      other_tree.each { |node| two << node }
      one == two
    end

    # Saves the tree as an SGF file. raises an error if a filename is not given.
    # tree.save :filename => file_name
    def save args={}
      raise ArgumentError, "No file name provided" if args[:filename].nil?
      @savable_sgf = "("
      @root.children.each { |child| write_node child }
      @savable_sgf << ")"

      File.open(args[:filename], 'w') { |f| f << @savable_sgf }
    end

    private

    # Adds a stringified node to the variable @savable_sgf.
    def write_node node=@root
      @savable_sgf << ";"
      unless node.properties.empty?
        properties = ""
        node.properties.each do |identity, property|
          new_property = property[1...-1]
          new_property.gsub!("]", "\\]") if identity == "C"
          properties += "#{identity.to_s}[#{new_property}]"
        end
        @savable_sgf << properties
      end

      case node.children.size
        when 0
          @savable_sgf << ")"
        when 1
          write_node node.children[0]
        else
          node.each_child do |child|
            @savable_sgf << "("
            write_node child
          end
      end
    end

    # Traverse the tree in preorder fashion, starting with the @root node if
    # no node is given, and activating the passed block on each.
    def preorder node=@root, &block
      # stop processing if the block returns false
      if yield node then
        node.each_child do |child|
          preorder(child, &block)
        end
      end
    end

    def method_missing method_name, *args
      output = @root.children[0].properties[method_name]
      super(method_name, args) if output.nil?
      output
    end

  end

end

