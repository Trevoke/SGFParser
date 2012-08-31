require 'delegate'
module SGF
  class Branch
    include Enumerable
    extend Forwardable

    def_delegators :@nodes, :size, :[]

    def initialize *nodes
      @nodes = nodes
    end

    def each
      @nodes.each { |n| yield n }
    end
  end
end