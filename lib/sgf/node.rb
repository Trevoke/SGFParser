# typed: true
# frozen_string_literal: true

require 'observer'
# Your basic node. It holds information about itself, its parent, and its children.
class SGF::Node
  include Observable
  include Enumerable

  extend ::T::Sig

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
    self.parent = parent # opts.delete :parent
    add_children children # opts.delete :children
    add_properties opts
  end

  # Set the given node as a parent and self as one of that node's children
  sig { params(parent: T.nilable(SGF::Node)).returns(SGF::Node) }
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

  sig { returns(SGF::Node) }
  def remove_parent
    set_parent(nil)
    self # This shouldn't need to be here, what's sorbet doing?
  end

  sig { params(node: SGF::Node).returns(TrueClass) }
  def remove_child(node)
    children.delete(node)
    delete_observer(node)
    true
  end

  sig { params(new_depth: Integer).returns(T::Boolean) }
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
  sig { params(hash: Hash).returns(SGF::Node) }
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
  sig {
    params(
      _block: T.proc.params(arg0: SGF::Node).void
    ).returns(T::Array[SGF::Node])
  }
  def each_child(&_block)
    @children.each { |child| yield child }
  end

  # Compare to another node.
  sig { params(other_node: SGF::Node).returns(T::Boolean) }
  def ==(other_node)
    @properties == other_node.properties
  end

  # Syntactic sugar for node.properties["XX"]
  sig { params(identity: T.any(NilClass, Symbol, String)).returns(T.any(String, T::Array, NilClass))}
  def [](identity)
    @properties[flexible(identity)]
  end

  sig {
    params(
      identity: T.any(Symbol, String),
      new_value: T.any(String, T::Array)
    ).returns(T.any(String, T::Array))
  }
  def []=(identity, new_value)
    @properties[flexible(identity)] = new_value
  end

  sig { returns(String) }
  def inspect
    out = "#<#{self.class}:#{object_id}, "
    out += (@parent ? 'Has a parent, ' : 'Has no parent, ')
    out += "#{@children.size} Children, "
    out += "#{@properties.keys.size} Properties"
    out += '>'
  end

  sig { params(indent: Integer).returns(String) }
  def to_s(indent = 0)
    properties = []
    @properties.each do |identity, property|
      properties << stringify_identity_and_property(identity, property)
    end
    whitespace = leading_whitespace(indent)
    "#{whitespace};#{properties.join("\n#{whitespace}")}"
  end

  # Observer pattern
  sig { params(message: Symbol, data: T.untyped).void }
  def update(message, data)
    case message
    when :depth_change then
      set_depth(data + 1)
    end
  end

  private

  sig { params(id: T.any(NilClass, String, Symbol)).returns(String) }
  def flexible(id)
    id.to_s.upcase
  end

  sig {
    params(
      node: SGF::Node,
      block: T.proc.params(arg0: SGF::Node).void
    ).void
  }
  def preorder(node = self, &block)
    yield node
    node.each_child do |child|
      preorder child, &block
    end
  end

  sig { params(indent: Integer).returns(String) }
  def leading_whitespace(indent)
    ' ' * indent
  end

  sig {
    params(method_name: Symbol, args: T.any(String, T::Array[String]))
      .returns(T.any(T.noreturn, String, T::Array[String]))
  }
  def method_missing(method_name, *args)
    property = flexible(method_name)
    if property[/(.*?)=$/]
      @properties[Regexp.last_match(1)] = args[0]
    else
      @properties.fetch(property, nil) || super(method_name, args)
    end
  end

  # sig { params(identity: String, property: T.any(String, T::Array))}
  def stringify_identity_and_property(identity, property)
    new_property = property.instance_of?(Array) ? property.join('][') : property
    new_id = flexible identity
    new_property = new_property.gsub(']', '\\]') if new_id == 'C'
    "#{new_id}[#{new_property}]"
  end
end
