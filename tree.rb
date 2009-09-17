require 'node'
#TODO It's still just a damn list! Have to make it into a tree!
class SGFTree

  attr_accessor :root, :sgf

  def initialize string = ""
    @root = SGFNode.new :number => -1, :previous => nil
    @sgf = ""
    File.open(string, 'r') { |f| @sgf = f.read }
    parse unless @sgf.empty?
  end
  
  def each
    node_list = []
  end

  private

  def parse
    # Getting rid of newlines.
    @sgf.gsub! "\\\\n\\\\r", ""
    @sgf.gsub! "\\\\r\\\\n", ""
    @sgf.gsub! "\\\\r", ""
    @sgf.gsub! "\\\\n", ""
    @sgf.gsub! "\n", " "
    #previous = @root # Initialize : first is the root, then...
    branches = [] # This stores where new branches are open
    current = @root
    node_number = 0 # Clearly the next node's depth is 0...
    identprop = false # We are not in the middle of an identprop value.
    content = Hash.new # Hash holding all the properties
    param, property = "", "" # Variables holding the properties
    end_of_a_series = false # To keep track of params with multiple properties

    # Simplest way is probably to iterate through every character, and use
    # a case scenario
    @sgf.each_char do |char|
      case char
      when '('  # Opening a new branch
        identprop ? (property += char) : (branches.push current)

      when ')' # Closing a branch

        if identprop
          property += char
        else
          # back to correct node.
          current = branches.pop
        end

      when ';' # Opening a new node
        if identprop
          property += char
        else
          # Make the current node the old node, make new node, store data
          previous = current
          current = SGFNode.new :previous => previous, :number => node_number
          previous.add_properties content
          previous.add_next current
          param, property = "", ""
          content.clear
        end

      when '[' # Open comment?
        if identprop
          property += char
        else # If we're not inside a comment, then now we are.
          identprop = true
          end_of_a_series = false
        end

      when ']' # Close comment
        end_of_a_series = true # Maybe end of a series of comments.
        identprop = false # That's our cue to close a comment.
        content[param] ||= []
        content[param] << property
        property = ""
      when '\]'
        identprop ? (property += char) : param += char
      when ' '
        identprop ? (property += char) : next

      else
        # Well, I guess it's "just" a character after all.
        if end_of_a_series
          end_of_a_series = false
          param, property = "", ""
        end
        identprop ? (property += char) : param += char
      end

    end
  end

  def method_missing method_name, *args
    output = @root.next[0].properties[method_name]
    super if output.nil?
    output
  end

end