module SgfParser

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

    def add_children *nodes
      nodes.flatten!
      raise "Non-node child given!" if nodes.find { |node| node.class != Node }
      # This node becomes the proud parent of one or more node!
      nodes.each { |node| node.parent = self }
      @children.concat nodes
    end

    def add_properties hash
      hash.each do |key, value|
        @properties[key] ||= ""
        @properties[key].concat value
      end
    end

    def each_child
      @children.each { |child| yield child }
    end

    def == other_node
      @properties == other_node.properties
    end

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