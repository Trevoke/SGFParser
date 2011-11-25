module SGF
  class Writer

    def initialize root, filename
      @root = root
      @filename = filename
    end

    def save
      @savable_sgf = ""
      #write_node @root
      @root.children.each do |child|
        @savable_sgf << "("
        write_node child
      end

      File.open(@filename, 'w') { |f| f << @savable_sgf }
    end

    # Adds a stringified node to the variable @savable_sgf.
    def write_node node=@root
      @savable_sgf << ";"
      properties = ""
      node.properties.each do |identity, property|
        properties << translate_pair_to_string(identity, property)
      end
      @savable_sgf << properties

      case node.children.size
        when 0 then
          @savable_sgf << ")"
        when 1 then
          write_node node.children[0]
        else
          node.each_child do |child|
            @savable_sgf << "("
            write_node child
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