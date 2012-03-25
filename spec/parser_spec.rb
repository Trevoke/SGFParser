require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SGF::Parser" do

  it "should give an error if the first two character are not (;" do
    parser = sgf_parser
    expect { parser.parse ';)' }.to raise_error SGF::MalformedDataError
  end

  it "should not give an error if it is told to sit down and shut up" do
    parser = sgf_parser
    expect { parser.parse ';)', false }.to_not raise_error
  end

  it "should parse a simple node" do
    parser = sgf_parser
    tree = parser.parse ";PW[Dosaku]", false
    tree.root.children[0].pw.should eq "Dosaku"
  end

  it "should parse a node with two properties" do
    parser = sgf_parser
    tree = parser.parse ";PB[Aldric]PW[Bob]", false
    tree.root.children[0].pb.should eq "Aldric"
    tree.root.children[0].pw.should eq "Bob"
  end

  it "should parse two nodes with one property each" do
    parser = sgf_parser
    tree = parser.parse ";PB[Aldric];PW[Bob]", false
    node = tree.root.children[0]
    node.pb.should eq "Aldric"
    node.children[0].pw.should eq "Bob"
  end

  it "should parse a tree with a single branch" do
    parser = sgf_parser
    tree = parser.parse "(;FF[4]PW[Aldric]PB[Bob];B[qq])"
    node = tree.root.children[0]
    node.pb.should eq "Bob"
    node.pw.should eq "Aldric"
    node.children[0].b.should eq "qq"
  end

  it "should parse a tree with two branches" do
    parser = sgf_parser
    tree = parser.parse "(;FF[4](;C[main])(;C[branch]))"
    node = tree.root.children[0]
    node.ff.should eq "4"
    node.children.size.should eq 2
    node.children[0].c.should eq "main"
    node.children[1].c.should eq "branch"
  end

  it "should parse a comment with a \\] inside" do
    parser = sgf_parser
    tree = parser.parse "(;C[Oh hi\\] there])"
    tree.root.children[0].c.should eq "Oh hi] there"
  end

  it "should parse a multi-property identity well" do
    parser = sgf_parser
    tree = parser.parse "(;FF[4];AW[bd][cc][qr])"
    tree.root.children[0].children[0].aw.should eq %w(bd cc qr)
  end

  it "should parse multiple trees" do
    parser = sgf_parser
    tree = parser.parse "(;FF[4]PW[Aldric];AW[dd][cc])(;FF[4]PW[Hi];PB[ad])"
    tree.root.children.size.should eq 2
    tree.root.children[0].children[0].aw.should eq %w(dd cc)
    tree.root.children[1].children[0].pb.should eq "ad"
  end

  it "should not put (; into the identity when separated by line breaks" do
    parser = sgf_parser
    tree = parser.parse "(;FF[4]\n\n(;B[dd])(;B[da]))"
    game = tree.root.children[0]
    game.children.size.should eq 2
    game.children[0].b.should eq "dd"
    game.children[1].b.should eq "da"
  end

  it "should parse the simplified sample SGF" do
    parser = sgf_parser
    tree = parser.parse SIMPLIFIED_SAMPLE_SGF
    root = tree.root
    root.children.size.should eq 2
    node = root.children[0].children[0]
    node.ar.should eq %w(aa:sc sa:ac aa:sa aa:ac cd:cj gd:md fh:ij kj:nh)
  end

  it "should parse a file if given a file handler as input" do
    parser = sgf_parser
    file = File.open 'spec/data/simple.sgf'
    tree = parser.parse file
    game = tree.games.first
    game.white_player.should eq "redrose"
    game.black_player.should eq "tartrate"
  end

  it "should parse a file if given a local path as input" do
    parser = sgf_parser
    local_path = 'spec/data/simple.sgf'
    tree = parser.parse local_path
    game = tree.games.first
    game.white_player.should eq "redrose"
    game.black_player.should eq "tartrate"
  end

  private

  def sgf_parser
    SGF::Parser.new
  end

end
