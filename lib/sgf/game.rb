module SGF
  class Game
    #Points to the current node in the game
    attr_accessor :current_node, :root

    #Takes a SGF::Node as an argument
    def initialize node
      raise ArgumentError, "Expected SGF::Node argument but received #{node.class}" unless node.instance_of? SGF::Node
      @root = node
      @current_node = node
    end

    #A simple way to go to the next node in the same branch of the tree
    def next_node
      @current_node = @current_node.children[0]
    end
    
  end
end