module SGF

  class Node

    attr_accessor :parent, :children, :properties

    def initialize args={}
      @parent = args[:parent]
      @children = []
      add_children args[:children] if !args[:children].nil?
      @properties = Hash.new
      @properties.merge! args[:properties] if !args[:properties].nil?

    end

    # Seemed necessary, will look for more graceful solution.
    def add_children node
      @children << node
    end

    def add_properties hash
      hash.each do |key, value|
        @properties[key] ||= ""
        @properties[key].concat value
      end
    end

    def each_child
      @children.each { |child| yield child }
    end

    def == other_node
      @properties == other_node.properties
    end

    #def inspect
    #  @properties
    #end

    # Making comments easier to access.
    def comments
      @properties["C"]
    end

    alias :comment :comments

    private

    def method_missing method_name, *args
      output = @properties[method_name.to_s.upcase]
      super(method_name, args) if output.nil?
      output
    end

  end

end