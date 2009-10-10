class SGFNode

  attr_accessor :next, :previous, :number, :properties

  def initialize args={}
    @next = []
    add_next args[:next] if !args[:next].nil?
    @number = args[:number] rescue nil
    @previous = args[:previous] rescue nil
    @properties = Hash.new
    @properties.merge args[:properties] if !args[:properties].nil?

  end

  def add_next node # Seemed necessary, will look for more graceful solution.
    @next << node
  end

  def add_properties hash
    hash.each do |key, value|
      identity = key.to_sym
      @properties[identity] ||= []
      @properties[identity].concat value
    end
  end

  def C
    return @properties[:C]
  end

  alias :c :C
  alias :comments :C
  alias :comment :C
  # Just trying to make it easy to get to the comments.

  def method_missing method_name, *args
    output = @properties[method_name]
    output.nil? ? super : output
    #output
  end

end
