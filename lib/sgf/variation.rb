module SGF
  class Variation
    attr_reader :root
    def initialize 
      @root = Node.new
      @size = 1
    end

    def append node
      @root.add_children node
      @size += 1
    end

    def size
      @size
    end
  end
end
