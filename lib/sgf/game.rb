module SGF
  class Game
    #Points to the current node in the game
    attr_accessor :current_node

    #Takes a SGF::Node as an argument
    def initialize node
      raise ArgumentError, "Expected SGF::Node argument but received #{node.class}" unless node.instance_of? SGF::Node
      @current_node = node
    end
  end
end