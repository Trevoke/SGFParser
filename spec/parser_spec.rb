require 'spec_helper'

describe SGF::Parser do

  let(:parser) { SGF::Parser.new }

  it "should give an error if the first two character are not (;" do
    expect { parser.parse ';)' }.to raise_error SGF::MalformedDataError
  end

  it "should not give an error if it is told to sit down and shut up" do
    expect { parser.parse ';)', false }.to_not raise_error
  end

  it "should parse a simple node" do
    collection = parser.parse ";PW[Dosaku]", false
    collection.root.children[0].pw.should eq "Dosaku"
  end

  it "should parse a node with two properties" do
    collection = parser.parse ";PB[Aldric]PW[Bob]", false
    collection.root.children[0].pb.should eq "Aldric"
    collection.root.children[0].pw.should eq "Bob"
  end

  it "should apparently ignore line breaks in the middle of a property name -- is this right?" do
    collection = parser.parse ";P\nB[Aldric]P\n\n\nW[Bob]", false
    collection.root.children[0].pb.should eq "Aldric"
    collection.root.children[0].pw.should eq "Bob"
  end

  it "should parse two nodes with one property each" do
    collection = parser.parse ";PB[Aldric];PW[Bob]", false
    node = collection.root.children[0]
    node.pb.should eq "Aldric"
    node.children[0].pw.should eq "Bob"
  end

  it "should parse a tree with a single branch" do
    collection = parser.parse "(;FF[4]PW[Aldric]PB[Bob];B[qq])"
    node = collection.root.children[0]
    node.pb.should eq "Bob"
    node.pw.should eq "Aldric"
    node.children[0].b.should eq "qq"
  end

  it "should parse a tree with two branches" do
    collection = parser.parse "(;FF[4](;C[main])(;C[branch]))"
    node = collection.root.children[0]
    node.ff.should eq "4"
    node.children.size.should eq 2
    node.children[0].c.should eq "main"
    node.children[1].c.should eq "branch"
  end

  it "should parse a comment with a \\] inside" do
    collection = parser.parse "(;C[Oh hi\\] there])"
    collection.root.children[0].c.should eq "Oh hi] there"
  end

  it "should parse a multi-property identity well" do
    collection = parser.parse "(;FF[4];AW[bd][cc][qr])"
    collection.root.children[0].children[0].aw.should eq %w(bd cc qr)
  end

  it "should parse multiple trees" do
    collection = parser.parse "(;FF[4]PW[Aldric];AW[dd][cc])(;FF[4]PW[Hi];PB[ad])"
    collection.root.children.size.should eq 2
    collection.root.children[0].children[0].aw.should eq %w(dd cc)
    collection.root.children[1].children[0].pb.should eq "ad"
  end

  it "should not put (; into the identity when separated by line breaks" do
    collection = parser.parse "(;FF[4]\n\n(;B[dd])(;B[da]))"
    game = collection.root.children[0]
    game.children.size.should eq 2
    game.children[0].b.should eq "dd"
    game.children[1].b.should eq "da"
  end

  it "should parse the simplified sample SGF" do
    collection = parser.parse SIMPLIFIED_SAMPLE_SGF
    root = collection.root
    root.children.size.should eq 2
    node = root.children[0].children[0]
    node.ar.should eq %w(aa:sc sa:ac aa:sa aa:ac cd:cj gd:md fh:ij kj:nh)
  end

  it "should parse a file if given a file handler as input" do
    file = File.open 'spec/data/simple.sgf'
    collection = parser.parse file
    game = collection.gametrees.first
    game.white_player.should eq "redrose"
    game.black_player.should eq "tartrate"
  end

  it "should parse a file if given a local path as input" do
    local_path = 'spec/data/simple.sgf'
    collection = parser.parse local_path
    game = collection.gametrees.first
    game.white_player.should eq "redrose"
    game.black_player.should eq "tartrate"
  end

end
