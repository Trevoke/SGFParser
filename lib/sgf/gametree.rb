module SGF
  class Gametree

    include Enumerable

    SGF::Gametree::PROPERTIES.each do |human_readable_method, sgf_identity|
      define_method(human_readable_method.to_sym) do
        @root.properties.fetch :sgf_identity do
          raise SGF::NoIdentityError
        end
      end
    end

    attr_accessor :current_node, :root

    #Takes a SGF::Node as an argument. It will be a problem if that node isn't
    #really the first node of of a game (ie: no FF property)
    def initialize node
      raise ArgumentError, "Expected SGF::Node argument but received #{node.class}" unless node.instance_of? SGF::Node
      @root = node
      @current_node = node
    end

    #A simple way to go to the next node in the same branch of the tree
    def next_node
      @current_node = @current_node.children[0]
    end

    #Iterate through all the nodes in preorder fashion
    def each &block
      @root.each &block
    end

    def node_count
      count = 0
      each { count += 1 }
      count
    end

    def to_s
      "<SGF::Game:#{object_id}>"
    end

    alias :inspect :to_s

    def to_str
      SGF::Writer.new.stringify_tree_from @root
    end

    def slice range
      new_root = nil
      each do |node|
        if node.depth == range.begin
          new_root = node.dup
          break
        end
      end

      new_root ||= @root.dup
      new_root.depth = 0
      new_root.parent = nil
      SGF::Gametree.new new_root
    end

    private

    def method_missing method_name, *args
      human_readable_identity = method_name.to_s.downcase
      identity = SGF::Gametree::PROPERTIES[human_readable_identity]
      return @root[identity] if identity
      super(method_name, args)
    end

  end
end
