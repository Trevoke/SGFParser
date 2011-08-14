module SGF

  #Tree holds most of the logic, for now. It has all the nodes, can iterate over them, and can even save to a file!
  #Somehow this feels like it should be split into another class or two...
  class Tree
    include Enumerable

    attr_accessor :root, :current_node

    # This is not something a user is ever going to initialize - interaction will be done
    # through the Parser class.
    def initialize
      @root = Node.new
      @current_node = @root
    end
  
    def each
      games.each {|game| game.each {|node| yield node }}
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

    # Saves the tree as an SGF file. raises an error if a filename is not given.
    # tree.save :filename => file_name
    def save args={}
      raise ArgumentError, "No file name provided" if args[:filename].nil?
      @savable_sgf = "("
      @root.children.each { |child| write_node child }
      @savable_sgf << ")"

      File.open(args[:filename], 'w') { |f| f << @savable_sgf }
    end


    #Returns an array of the Game objects in this tree.
    def games
      @games ||= populate_game_array
    end

    private

    def populate_game_array
      games = []
      @root.children.each do |first_node_of_gametree|
        games << Game.new(first_node_of_gametree)
      end
      games
    end

    # Adds a stringified node to the variable @savable_sgf.
    def write_node node=@root
      @savable_sgf << ";"
      unless node.properties.empty?
        properties = ""
        node.properties.each do |identity, property|
          new_property = property[1...-1]
          new_property.gsub!("]", "\\]") if identity == "C"
          properties += "#{identity.to_s}[#{new_property}]"
        end
        @savable_sgf << properties
      end

      case node.children.size
        when 0
          @savable_sgf << ")"
        when 1
          write_node node.children[0]
        else
          node.each_child do |child|
            @savable_sgf << "("
            write_node child
          end
      end
    end

    def method_missing method_name, *args
      output = @root.children[0].properties[method_name]
      super(method_name, args) if output.nil?
      output
    end

  end

end

