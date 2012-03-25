require 'set'
module SGF

  #Your basic node. It holds information about itself, its parent, and its children.
  class Node
    include Enumerable

    attr_accessor :children, :properties, :depth

    # Creates a new node. Arguments which can be passed in are:
    # :parent => parent_node (nil by default)
    # :children => [list, of, children] (empty array if nothing is passed)
    # :properties => {hash_of => properties} (empty hash if nothing is passed)
    def initialize args={}
      opts = {children: [], properties: {}, parent: nil}
      opts.merge! args
      @depth = 0
      @children = []
      set_parent opts[:parent]
      add_children opts[:children]
      add_properties opts[:properties]
    end

    def parent
      @parent
    end

    def parent= parent
      return unless parent
      if @parent
        @parent.children.delete self
      end
      @parent = parent
      parent.children << self
      self.each do |node|
        node.depth = node.parent.depth + 1
      end
    end

    alias :set_parent :parent=

    #Takes an arbitrary number of child nodes, adds them to the list of children, and make this node their parent.
    def add_children *nodes
      nodes.flatten.each do |node|
        node.parent= self
      end
    end

    #Takes a hash {identity => property} and adds those to the current node.
    #If a property already exists, it will append to it.
    def add_properties hash
      @properties ||= {}
      hash.each do |identity, property|
        @properties[identity] ||= property.class.new
        @properties[identity].concat property
      end
      update_human_readable_methods
    end

    def each &block
      preorder self, &block
    end

    #Iterate through and yield each child. 
    def each_child
      @children.each { |child| yield child }
    end

    #Compare to another node.
    def == other_node
      @properties == other_node.properties
    end

    #Syntactic sugar for node.properties["XX"]
    def [] identity
      identity = identity.to_s
      @properties[identity]
    end

    def to_s
      out = "#<#{self.class}:#{self.object_id}, "
      out << (@parent ? "Has a parent, " : "Has no parent, ")
      out << "#{@children.size} Children, "
      out << "#{@properties.keys.size} Properties"
      out << ">"
    end

    alias :inspect :to_s

    def to_str(indent = 0)
      properties = []
      @properties.each do |identity, property|
        properties << stringify_identity_and_property(identity, property)
      end
      whitespace = leading_whitespace(indent)
      "#{whitespace};#{properties.join("\n#{whitespace}")}"
    end

    def stringify_identity_and_property(identity, property)
      new_property = property.instance_of?(Array) ? property.join("][") : property
      new_property = new_property.gsub("]", "\\]") if flexible(identity) == "C"
      "#{identity.to_s}[#{new_property}]"
    end

    private

    def flexible id
      id.to_s.upcase
    end

    def update_human_readable_methods
      SGF::Node::PROPERTIES.each do |human_readable_method, sgf_identity|
        next if defined? human_readable_method.to_sym
        define_method(human_readable_method.to_sym) do
          @properties[sgf_identity] ? @properties[sgf_identity] : raise(SGF::NoIdentityError)
        end
      end
    end

    def preorder node=self, &block
      yield node
      node.each_child do |child|
        preorder child, &block
      end
    end

    def leading_whitespace(indent)
      "#{" " * indent}"
    end

    def method_missing method_name, *args
      property = flexible(method_name)
      if property[/(.*?)=$/]
        @properties[$1] = args[0]
      else
        output = @properties[property]
        super(method_name, args) if output.nil?
        output
      end
    end

  end

end
