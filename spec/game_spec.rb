require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SGF::Game" do

  before :each do
    @game = parse_example_gametree
  end

  it "should hold the first node of the game" do
    @game.current_node["FF"].should == "[4]"
  end

  it "should throw up if initialized with a non-Node argument" do
    expect { SGF::Game.new("I am a string")}.to raise_error(ArgumentError)
    expect { SGF::Game.new(SGF::Node.new)}.to_not raise_error(ArgumentError)
  end

  it "should have 'root' as the default current node" do
    @game.current_node.should == @game.root
  end

  it "should have a nice way to go to children[0]" do
    @game.next_node
    @game.current_node.should == @game.root.children[0]
  end

  it "should have a way of setting an arbitrary node to the current node" do
    @game.current_node = @game.root.children[3]
    @game.current_node.properties.keys.sort.should == ["B", "C", "N"]
    @game.current_node.children.size.should == 6
  end

end

def parse_example_gametree
  parser = SGF::Parser.new
  tree = parser.parse('spec/data/ff4_ex.sgf')
  game = tree.games.first
  game
end