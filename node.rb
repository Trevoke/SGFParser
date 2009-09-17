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

  def add_next node
    @next << node
  end

  def add_properties hash
    #puts
    #pp hash
    #puts
    hash.each do |key, value|
      ident = key.to_sym 
      #pp ident, value
      @properties[ident] ||= [] 
      @properties[ident].concat value 
    end
  end

end