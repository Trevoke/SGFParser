module SGF
  class Game

    include Enumerable

    SGF::Game::PROPERTIES.each do |human_readable_method, sgf_identity|
      define_method(human_readable_method.to_sym) do
        @root[sgf_identity] ? @root[sgf_identity] : raise(SGF::NoIdentityError)
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
      preorder @root, &block
    end

    private

    def method_missing method_name, *args
      human_readable_identity = method_name.to_s.downcase
      identity = SGF::Game::PROPERTIES[human_readable_identity]
      return @root[identity] if identity
      super(method_name, args)
    end

    def preorder node=@root, &block
      # stop processing if the block returns false
      if yield node then
        node.each_child do |child|
          preorder(child, &block)
        end
      end
    end
  end
end