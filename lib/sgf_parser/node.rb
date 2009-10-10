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

  def method_missing method_name, *args
    output = @properties[method_name]
    super if output.nil?
    output
  end

end
