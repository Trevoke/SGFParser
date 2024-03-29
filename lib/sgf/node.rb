# frozen_string_literal: true

require 'observer'
# Your basic node. It holds information about itself, its parent, and its children.
class SGF::Node
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
    @parent = nil
    @children = []
    @properties = {}
    remove_parent
    self.parent = parent # opts.delete :parent
    add_children children # opts.delete :children
    add_properties opts
  end

  # Set the given node as a parent and self as one of that node's children
  def parent=(parent)
    if @parent
      @parent.remove_child(self)
    end

    @parent = parent

    if @parent
      @parent.children << self
      @parent.add_observer self
      set_depth @parent.depth + 1
    else
      set_depth 0
    end

    self
  end

  alias set_parent parent=

  def remove_parent
    set_parent(nil)
    self # This shouldn't need to be here, what's sorbet doing?
  end

  def remove_child(node)
    children.delete(node)
    delete_observer(node)
    true
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
    nodes.flatten.each do |node|
      node.set_parent self
    end
    changed
    notify_observers :new_children, nodes.flatten
  end

  # Takes a hash {identity => property} and adds those to the current node.
  # If a property already exists, it will append to it.
  def add_properties(hash)
    hash.each do |identity, property|
      @properties[flexible identity] ||= property.class.new
      @properties[flexible identity].concat property
    end
    self
  end

  def each(&block)
    preorder self, &block
  end

  # Iterate through and yield each child.
  def each_child(&_block)
    @children.each { |child| yield child }
  end

  # Compare to another node.
  def ==(other_node)
    @properties == other_node.properties
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
    properties = []
    @properties.each do |identity, property|
      properties << stringify_identity_and_property(identity, property)
    end
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

  def preorder(node = self, &block)
    yield node
    node.each_child do |child|
      preorder child, &block
    end
  end

  def leading_whitespace(indent)
    ' ' * indent
  end

  def method_missing(method_name, *args)
    property = flexible(method_name)
    if property[/(.*?)=$/]
      @properties[Regexp.last_match(1)] = args[0]
    else
      @properties.fetch(property, nil) || super(method_name, args)
    end
  end

  def stringify_identity_and_property(identity, property)
    new_property = property.instance_of?(Array) ? property.join('][') : property
    new_id = flexible identity
    new_property = new_property.gsub(']', '\\]') if new_id == 'C'
    "#{new_id}[#{new_property}]"
  end
end
