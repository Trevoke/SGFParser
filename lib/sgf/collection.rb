module SGF

  #Collection holds most of the logic, for now. It has all the nodes, can iterate over them, and can even save to a file!
  #Somehow this feels like it should be split into another class or two...
  class Collection
    include Enumerable

    attr_accessor :root, :current_node, :errors

    def initialize
      @root = Node.new
      @current_node = @root
      @errors = []
    end

    def each
      gametrees.each { |game| game.each { |node| yield node } }
    end

    # Compares a tree to another tree, node by node.
    # Nodes must be the same (same properties, parents and children).
    def == other_collection
      one = []
      two = []
      each { |node| one << node }
      other_collection.each { |node| two << node }
      one == two
    end

    #Returns an array of the Game objects in this tree.
    def gametrees
      populate_game_array
    end

    def to_s
      out = "#<SGF::Collection:#{self.object_id}, "
      out << "#{gametrees.count} Games, "
      out << "#{node_count} Nodes"
      out << ">"
    end

    alias :inspect :to_s

    def to_str
      SGF::Writer.new.stringify_tree_from @root
    end

    # Saves the Collection as an SGF file. Takes a filename as argument.
    def save filename
      SGF::Writer.new.save(@root, filename)
    end

    private

    def node_count
      count = 0
      gametrees.each { |game| count += game.node_count }
      count
    end

    def populate_game_array
      games = []
      @root.children.each do |first_node_of_tree|
        games << Gametree.new(first_node_of_tree)
      end
      games
    end

    def method_missing method_name, *args
      output = @root.children[0].properties[method_name]
      super(method_name, args) if output.nil?
      output
    end

  end # Collection
end # SGF

