module SgfParser

  # Each part of the SGF Tree is a node. This holds links to the parent node,
  # to the next node(s) in the tree, and of course, the properties of said node.
  # Accessors : node.parent, node.children, node.properties
  class Node

    attr_accessor :parent, :children, :properties

    # Creates a new node. Options which can be passed in are:
    # :parent => parent_node (nil by default)
    # : children => [list, of, children] (empty array by default)
    # :properties => {hash_of => properties} (empty hash by default)
    def initialize args={}
      @parent = args[:parent]
      @children = []
      add_children args[:children] if !args[:children].nil?
      @properties = Hash.new
      @properties.merge! args[:properties] if !args[:properties].nil?
    end

    # Adds one child or several children. Can be passed in as a comma-separated
    # list or an array of node children. Will raise an error if one of the
    # arguments is not of class Node.
    def add_children *nodes
      nodes.flatten!
      raise "Non-node child given!" if nodes.find { |node| node.class != Node }
      # This node becomes the proud parent of one or more node!
      nodes.each { |node| node.parent = self }
      @children.concat nodes
    end

    # Adds one or more properties to the node.
    # Argument: a hash {'property' => 'value'}
    def add_properties hash
      hash.each do |key, value|
        @properties[key] ||= ""
        @properties[key].concat value
      end
    end

    # Iterates over each child of the given node
    # node.each_child { |child| puts child.properties }
    def each_child
      @children.each { |child| yield child }
    end

    # Compares one node's properties to another node's properties
    def == other_node
      @properties == other_node.properties
    end

    # Making comments easier to access.
    def comments
      @properties["C"]
    end

    alias :comment :comments

    private

    def method_missing method_name, *args
      output = @properties[method_name.to_s.upcase]
      super(method_name, args) if output.nil?
      output
    end

  end

end