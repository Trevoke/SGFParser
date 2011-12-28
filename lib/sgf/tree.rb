module SGF

  #Tree holds most of the logic, for now. It has all the nodes, can iterate over them, and can even save to a file!
  #Somehow this feels like it should be split into another class or two...
  class Tree
    include Enumerable

    attr_accessor :root, :current_node, :errors

    def initialize
      @root = Node.new
      @current_node = @root
      @errors = []
    end

    def each
      games.each { |game| game.each { |node| yield node } }
    end

    # Compares a tree to another tree, node by node.
    # Nodes must be the same (same properties, parents and children).
    def == other_tree
      one = []
      two = []
      each { |node| one << node }
      other_tree.each { |node| two << node }
      one == two
    end

    #Returns an array of the Game objects in this tree.
    def games
      @games ||= populate_game_array
    end

    def inspect
      out = "#<SGF::Tree:#{self.object_id}, "
      out << "#{games.count} Games, "
      out << "#{node_count} Nodes"
      out << ">"
    end

    def to_s
      inspect
    end

    def to_str
      SGF::Writer.new.stringify_tree_from @root
    end

    # Saves the Tree as an SGF file. Takes a filename as argument.
    def save filename
      SGF::Writer.new.save(@root, filename)
    end

    private

    def node_count
      count = 0
      each { |node| count += 1 }
      count
    end

    def populate_game_array
      games = []
      @root.children.each do |first_node_of_gametree|
        games << Game.new(first_node_of_gametree)
      end
      games
    end

    def method_missing method_name, *args
      output = @root.children[0].properties[method_name]
      super(method_name, args) if output.nil?
      output
    end
  end # Tree
end # SGF

