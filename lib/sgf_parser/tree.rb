#Find a way to make sure this gets loaded.. ? If packaged in a gem, non-issue.
#require 'node'

class SGFTree
  include Enumerable

  attr_accessor :root

  #Parsing a file is the default behavior, so if both file and string are provided,
  #File takes the precedence.
  def initialize args={}
    @root = SGFNode.new :number => -1, :previous => nil
    @sgf = ""

    if !args[:filename].nil?
      load_file args[:filename]
    elsif !args[:sgf_string].nil?
      load_string args[:sgf_string]
    end

  end

  def load_string string
    @sgf = string
    parse unless  @sgf.empty?
  end

  def load_file filename
    @sgf = ""
    File.open(filename, 'r') { |f| @sgf = f.read }
    parse unless @sgf.empty?
  end

  def each # Currently only returns the main branch. What else can I do?
    current = @root
    node_list = [current]
    until current.next.empty?
      #node_list.concat current.next
      current = current.next[0]
      node_list << current
    end
    node_list.each { |node| yield node }
  end

  private

  def parse
    # Getting rid of newlines. This may not be ideal. Time will tell.
    @sgf.gsub! "\\\\n\\\\r", ""
    @sgf.gsub! "\\\\r\\\\n", ""
    @sgf.gsub! "\\\\r", ""
    @sgf.gsub! "\\\\n", ""
    @sgf.gsub! "\n", ""
    branches = [] # This stores where new branches are open
    current = @root # Let's start at the beginning, shall we?
    node_number = 0 # Clearly the first real node's number is 0...
    identprop = false # We are not in the middle of an identprop value.
    # An identprop is an identity property - a value.
    content = Hash.new # Hash holding all the properties
    param, property = "", "" # Variables holding the idents and props
    end_of_a_series = false # To keep track of params with multiple properties

    sgf_array = @sgf.split(//)
    iterator = 0
    array_length = sgf_array.size
    previous_character = nil
    # Simplest way is probably to iterate through every character, and use a case scenario

    while iterator < array_length - 1 # I haven't written code this ugly since C++ :(
      char = sgf_array[iterator]

      case char
        when '(' # Opening a new branch
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
            node_number += 1
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

        when "\\" # If we're inside a comment, then maybe we're about to escape a ].
                  # This is the whole reason we need this ugly charade of a loop.
          if identprop
            if sgf_array[iterator + 1] == "]"
              property += "]"
              iterator += 1
            else
              property += "\\"
            end
          else
            #This should never happen - a backslash outside a comment ?!
            #But let's not have it be told that I'm not prepared.
            property += "\\"
          end

        #when '\]'
        #  identprop ? (property += char) : param += char
        #when ' '
        #  identprop ? (property += char) : next

        else
          # Well, I guess it's "just" a character after all.
          if end_of_a_series
            end_of_a_series = false
            param, property = "", ""
          end
          identprop ? (property += char) : param += char
      end

      iterator += 1
    end

=begin
   @sgf.each_char do |char|
      case char
        when '(' # Opening a new branch
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
=end

  end

  def method_missing method_name, *args
    output = @root.next[0].properties[method_name]
    super if output.nil?
    output
  end

end
