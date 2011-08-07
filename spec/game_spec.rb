require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SGF::Game" do

  it "should hold the first node of the game" do
    parser = SGF::Parser.new
    tree = parser.parse('spec/data/ff4_ex.sgf')
    game = tree.games.first
    game.current_node["FF"].should == "[4]"
  end

  it "should throw up if initialized with a non-Node argument" do
    expect { SGF::Game.new("I am a string")}.to raise_error(ArgumentError)
    expect { SGF::Game.new(SGF::Node.new)}.to_not raise_error(ArgumentError)
  end

end