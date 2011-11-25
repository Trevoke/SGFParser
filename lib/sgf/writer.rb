module SGF
  class Writer

    def initialize(root, filename)
      @root = root
      @filename = filename
    end

    def save
      @string = ""
      #write_tree_from @root
      @root.children.each do |node|
        @string << "("
        write_tree_from node
      end

      File.open(@filename, 'w') { |f| f << @string }
    end

    # Creates a stringified SGF tree from the given node.
    def write_tree_from node = @root
      @string << ";"
      properties = ""
      node.properties.each do |identity, property|
        properties << translate_pair_to_string(identity, property)
      end
      @string << properties

      case node.children.size
        when 0 then
          @string << ")"
        when 1 then
          write_tree_from node.children[0]
        else
          node.each_child do |child|
            @string << "("
            write_tree_from child
          end
      end
    end

    def translate_pair_to_string(identity, property)
      new_property = property.instance_of?(Array) ? property.join("][") : property
      new_property = new_property.gsub("]", "\\]") if identity == "C"
      "#{identity.to_s}[#{new_property}]"
    end
  end
end