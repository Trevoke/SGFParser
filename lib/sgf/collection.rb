# frozen_string_literal: true

# Collection holds most of the logic, for now.
# It has all the nodes, can iterate over them, and can even save to a file!
module SGF
  # mwa ha ha
  class Collection
    include Observable
    include Enumerable

    attr_accessor :current_node, :errors, :gametrees
    attr_reader :root

    def initialize(root = SGF::Node.new)
      @root = root
      @current_node = @root
      @root.add_observer(self)
      @errors = []
      @gametrees = @root.children.map do |root_of_tree|
        SGF::Gametree.new(root_of_tree)
      end
    end

    def each
      gametrees.each do |game|
        game.each do |node|
          yield node
        end
      end
    end

    def <<(gametree)
      unless gametree.instance_of?(SGF::Gametree)
        raise ArgumentError, "Expected instance of class SGF::Gametree but was instance of #{gametree.class}"
      end

      @root.add_children gametree.root
    end

    # Compares a tree to another tree, node by node.
    # Nodes must be the same (same properties, parents and children).
    def ==(other)
      map { |node| node } == other.map { |node| node }
    end

    def inspect
      out = "#<SGF::Collection:#{object_id}, "
      out += "#{gametrees.count} Games, "
      out += "#{node_count} Nodes"
      out += '>'
    end

    def to_s
      SGF::Writer.new.stringify_tree_from @root
    end

    # Saves the Collection as an SGF file. Takes a filename as argument.
    def save(filename)
      SGF::Writer.new.save(@root, filename)
    end

    def update(message, data)
      case message
      when :new_children
        data.each do |new_gametree_root|
          @gametrees << SGF::Gametree.new(new_gametree_root)
        end
      end
    end

    private

    def node_count
      gametrees.inject(0) { |sum, game| sum + game.count }
    end

    def method_missing(method_name, *args)
      super(method_name, args) if @root.children.empty? || !@root.children[0].properties.key?(method_name)
      @root.children[0].properties[method_name]
    end
  end
end
