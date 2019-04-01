# frozen_string_literal: true

require 'observer'
# Your basic node. It holds information about itself, its parent, and its children.
module SGF
  class Node
    include Observable
    include Enumerable

    attr_accessor :children, :properties
    attr_reader :parent, :depth

    # Creates a new node. You can pass in a hash. There are two special keys, parent and children.
    # * parent: parent_node (nil by default)
    # * children: [list, of, children] (empty array if nothing is passed)
    # Anything else passed to the hash will become an SGF identity/property pair on the node.
    def initialize(children: [], parent: nil, **opts)
      # opts = { children: [], parent: nil }
      # opts.merge! args
      @depth = 0
      @children = []
      @properties = {}
      @parent = nil
      set_parent parent # opts.delete :parent
      add_children children # opts.delete :children
      add_properties opts
    end

    # Set the given node as a parent and self as one of that node's children
    def parent=(parent)
      @parent&.remove_child(self)
      @parent = parent
      if @parent
        @parent.add_children(self)
        set_depth @parent.depth + 1
      else
        set_depth 0
      end
    end

    alias set_parent parent=

    def remove_parent
      set_parent nil
    end

    def depth=(new_depth)
      @depth = new_depth
      changed
      notify_observers :depth_change, @depth
    end

    alias set_depth depth=

    # Takes an arbitrary number of child nodes, adds them to the list of children,
    # and make this node their parent.
    def add_children(*nodes)
      new_children = nodes.flatten
      new_children.each do |node|
        node.set_parent self
        node.add_observer(self)
      end
      changed
      notify_observers :new_children, new_children
    end

    def remove_child(node)
      children.delete(node)
      delete_observer(node)
    end

    # Takes a hash {identity => property} and adds those to the current node.
    # If a property already exists, it will append to it.
    def add_properties(hash)
      hash.each do |identity, property|
        @properties[flexible identity] ||= property.class.new
        @properties[flexible identity].concat property
      end
      update_human_readable_methods
    end

    def each(&block)
      preorder self, &block
    end

    # Iterate through and yield each child.
    def each_child
      @children.each {|child| yield child}
    end

    # Compare to another node.
    def ==(other)
      @properties == other.properties
    end

    # Syntactic sugar for node.properties["XX"]
    def [](identity)
      @properties[flexible(identity)]
    end

    def []=(identity, new_value)
      @properties[flexible(identity)] = new_value
    end

    def inspect
      out = "#<#{self.class}:#{object_id}, "
      out += (@parent ? 'Has a parent, ' : 'Has no parent, ')
      out += "#{@children.size} Children, "
      out += "#{@properties.keys.size} Properties"
      out + '>'
    end

    def to_s(indent = 0)
      properties = @properties.map(&method(:stringify_identity_and_property))
      whitespace = leading_whitespace(indent)
      "#{whitespace};#{properties.join("\n#{whitespace}")}"
    end

    # Observer pattern
    def update(message, data)
      case message
      when :depth_change then
        set_depth(data + 1)
      end
    end

    private

    def flexible(id)
      id.to_s.upcase
    end

    def update_human_readable_methods
      SGF::Node::PROPERTIES
          .reject {|method_name, _sgf_identity| defined? method_name}
          .each do |human_readable_method, sgf_identity|
        define_method(human_readable_method.to_sym) do
          @properties[sgf_identity] || raise(SGF::NoIdentityError, "This node does not have #{sgf_identity} available")
        end
      end
    end

    def preorder(node = self, &block)
      yield node
      node.each_child do |child|
        preorder child, &block
      end
    end

    def leading_whitespace(indent)
      ' ' * indent
    end

    def respond_to_missing(name, _include_private = false)
      prop = flexible(name)
      @properties[prop] || @properties["#{prop}="]
    end

    def method_missing(method_name, *args)
      property = flexible(method_name)
      if property[/(.*?)=$/]
        @properties[Regexp.last_match(1)] = args[0]
      else
        @properties.fetch(property) {super(method_name, args)}
      end
    end

    def stringify_identity_and_property(identity, property)
      new_property = property.instance_of?(Array) ? property.join('][') : property
      new_id = flexible identity
      new_property = new_property.gsub(']', '\\]') if new_id == 'C'
      "#{new_id}[#{new_property}]"
    end
  end
end