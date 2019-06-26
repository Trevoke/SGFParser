# typed: true
# frozen_string_literal: true

# Collection holds most of the logic, for now.
# It has all the nodes, can iterate over them, and can even save to a file!
module SGF
  # mwa ha ha
  class Collection
    include Observable
    include Enumerable

    extend ::T::Sig

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

    sig {
      params(
        _block: T.proc.params(arg0: SGF::Node).void
      ).returns(SGF::Collection)
    }
    def each(&_block)
      gametrees.each do |game|
        game.each do |node|
          yield node
        end
      end
      self
    end

    sig {
      params(gametree: Gametree).returns(Collection)
    }
    def <<(gametree)
      @root.add_children gametree.root
    end

    # Compares a tree to another tree, node by node.
    # Nodes must be the same (same properties, parents and children).
    sig { params(other: Collection).returns(T::Boolean) }
    def ==(other)
      map { |node| node } == other.map { |node| node }
    end

    sig { returns(String) }
    def inspect
      out = "#<SGF::Collection:#{object_id}, "
      out += "#{gametrees.count} Games, "
      out += "#{node_count} Nodes"
      out + '>'
    end

    sig { returns(String) }
    def to_s
      SGF::Writer.new.stringify_tree_from @root
    end

    # Saves the Collection as an SGF file. Takes a filename as argument.
    sig { params(filename: String).returns(File) }
    def save(filename)
      SGF::Writer.new.save(@root, filename)
    end

    sig { params(message: Symbol, data: T::Array[Node]).returns(TrueClass)}
    def update(message, data)
      case message
      when :new_children
        data.each do |new_gametree_root|
          @gametrees << SGF::Gametree.new(new_gametree_root)
        end
      end
      true
    end

    private

    sig { returns(Integer) }
    def node_count
      gametrees.inject(0) { |sum, game| sum + game.count }
    end

    sig {
      params(method_name: Symbol, args: T::Array)
        .returns(T.any(T.noreturn, T::Array, String))
    }
    def method_missing(method_name, *args)
      if @root.children.empty? || !@root.children[0].properties.key?(method_name)
        super
      else
        @root.children[0].properties[method_name]
      end
    end

    sig { params(name: Symbol, _include_private: T::Boolean).returns(T::Boolean) }
    def respond_to_missing?(name, _include_private = false)
      @root.children[0].properties.key?(name)
    end
  end
end
