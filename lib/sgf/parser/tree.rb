module SgfParser

  # This is a placeholder for the root of the gametree(s). It's an abstraction,
  # but it allows an easy way to save, iterate over, and compare other trees.
  # Accessors: tree.root
  class Tree
    include Enumerable

    attr_accessor :root

    # Create a new tree. Can also be used to load a tree from either a file or
    # a string. Raises an error if both are provided.
    # options: \n
    # :filename => filename \n
    # !!! OR !!! \n
    # :sgf_string => string \n
    def initialize args={}
      @root = Node.new
      @sgf = ""
      raise ArgumentError, "Both file and string provided" if args[:filename] &&
                                                              args[:sgf_string]
      if !args[:filename].nil?
        load_file args[:filename]
      elsif !args[:sgf_string].nil?
        load_string args[:sgf_string]
      end

    end # initialize


    # Iterates over the tree, node by node, in preorder fashion.
    # Does not support other types of iteration, but may in the future.
    # tree.each { |node| puts "I am node. Hear me #{node.properties} !"}
    def each order=:preorder, &block
      case order
        when :preorder
          preorder @root, &block
      end
    end # each

    # Compares a tree to another tree, node by node.
    # Nodes must by the same (same properties, parents and children).
    def == other_tree
      one = []
      two = []
      each { |node| one << node }
      other_tree.each { |node| two << node }
      one == two
    end # ==

    # Saves the tree as an SGF file. raises an error if a filename is not given.
    # tree.save :filename => file_name
    def save args={}
      raise ArgumentError, "No file name provided" if args[:filename].nil?
      # SGF files are trees stored in pre-order traversal.
      @sgf_string = "("
      @root.children.each { |child| write_node child }
      # write_node @root
      @sgf_string << ")"

      File.open(args[:filename], 'w') { |f| f << @sgf_string }
    end #save

    private

    # Adds a stringified node to the variable @sgf_string - for saving purposes. 
    def write_node node=@root
      @sgf_string << ";"
      unless node.properties.empty?
        properties = ""
        node.properties.each do |k, v|
          v_escaped = v.gsub("]", "\\]")
          properties += "#{k.to_s}[#{v_escaped}]"
        end
        @sgf_string << "#{properties}"
      end

      case node.children.size
        when 0
          @sgf_string << ")"
        when 1
          write_node node.children[0]
        else
          node.each_child do |child|
            @sgf_string << "("
            write_node child
          end
      end
    end

    # Used to load and parse a string if a string was given.
    def load_string string
      @sgf = string
      parse unless @sgf.empty?
    end # load_string

    # Used to load and parse a file if a file was given.
    def load_file filename
      @sgf = ""
      File.open(filename, 'r') { |f| @sgf = f.read }
      parse unless @sgf.empty?
    end # load_file

    # Traverse the tree in preorder fashion, starting with the @root node if
    # no node is given, and activating the passed block on each.
    def preorder node=@root, &block
      # stop processing if the block returns false
      if yield node then
        node.each_child do |child|
          preorder(child, &block)
        end
      end
    end # preorder      

    def method_missing method_name, *args
      output = @root.children[0].properties[method_name]
      super(method_name, args) if output.nil?
      output
    end # method_missing    

  end

end

