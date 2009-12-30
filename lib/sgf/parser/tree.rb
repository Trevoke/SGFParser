module SGF

  class Tree
    include Enumerable

    attr_accessor :root

    # Errors out if both string and filename are provided. Requires one and
    # only one of those two arguments.
    def initialize args={}
      @root = Node.new
      @sgf = ""
      raise ArgumentError, "Both file and string provided" if args[:filename] &&
                                                              args[:sgf_string]
      if !args[:filename].nil?
        load_file args[:filename]
      elsif !args[:sgf_string].nil?
        load_string args[:sgf_string]
      end

    end # initialize

    def each order=:preorder, &block
      case order
        when :preorder
          preorder @root, &block
      end
    end # each

    def == other_tree
      require 'pp'
      one = []
      two = []
      preorder(@root) { |x| one << x.properties }
      other_tree.preorder(other_tree.root) { |x| two << x.properties }
      puts "one: #{one.size} and two: #{two.size}"
      one.each_with_index do |x, i|
        if x != two[i]
          puts i
          puts "_-/\\=/\\-_ ONE _-/\\=/\\-_"
          pp x
          puts "_-/\\=/\\-_ TWO _-/\\=/\\-_"
          pp two[i]
        end
      end
      one == two
    end # ==



    def save args={}
      raise ArgumentError, "No file name provided" if args[:filename].nil?
      # SGF files are trees stored in pre-order traversal.
      @sgf_string = "("
      @root.children.each { |child| write_node child }
      # write_node @root
      @sgf_string << ")"

      File.open(args[:filename], 'w') { |f| f << @sgf_string }
    end #save

    def preorder node=@root, &block
      # stop processing if the block returns false
      if yield node then
        node.each_child do |child|
          preorder(child, &block)
        end
      end
    end # preorder     

    private

    def write_node node=@root
      @sgf_string << ";"
      unless node.properties.empty?
        properties = ""
        node.properties.each do |k, v|
          v_escaped = v.gsub("]", "\\]")
          properties += "#{k.to_s}[#{v_escaped}]"
        end
        @sgf_string << "#{properties}"
      end

      case node.children.size
        when 0
          @sgf_string << ")"
        when 1
          write_node node.children[0]
        else
          node.each_child do |child|
            @sgf_string << "("
            write_node child
          end
      end
    end

    def load_string string
      @sgf = string
      parse unless @sgf.empty?
    end # load_string

    def load_file filename
      @sgf = ""
      File.open(filename, 'r') { |f| @sgf = f.read }
      parse unless @sgf.empty?
    end # load_file

    def method_missing method_name, *args
      output = @root.children[0].properties[method_name]
      super(method_name, args) if output.nil?
      output
    end # method_missing    

  end

end

