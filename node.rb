class SGFNode

  attr_accessor :next, :number, :depth, :properties

  def initialize args
    @next = []
    add_next args[:next] if !args[:next].nil?
    @number = args[:number] rescue nil
    @depth = args[:depth] rescue -1
    @properties = Hash.new
    @properties.merge args[:properties] if !args[:properties].nil?

  end

  def add_next node # Seemed necessary, will look for more graceful solution.
    @next << node
  end

  def add_properties hash
    hash.each do |key, value|
      ident = key.to_sym 
      @properties[ident] ||= [] 
      @properties[ident].concat value 
    end
  end
  
  def method_missing method_name, *args
    output = @properties[method_name]
    super if output.nil?
    output
  end

end
