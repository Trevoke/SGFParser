require 'spec_helper'

describe SGF::Parser do

  let(:parser) { SGF::Parser.new }

  describe "when given invalid SGF files" do
    it "should give an error if the first two character are not (;" do
      expect { parser.parse ';)' }.to raise_error SGF::MalformedDataError
    end

    it "should not give an error if it is told to sit down and shut up" do
      expect { parser.parse(';)', false) }.to_not raise_error
    end

    it "should properly parse a file that has many AB/AW/AE values in a single node" do
      invalid_sgf = "(;AB[dd]AB[aa])"
      collection = parser.parse invalid_sgf
      node = SGF::Node.new AB: %w[dd aa]
      expected = SGF::Collection.new
      expected.root.add_children node
      expect(collection).to eq expected
      expect(collection.errors).to include "Multiple AB identities are present in a single node. A property should only exist once per node."
    end
  end

  it "should parse a simple node" do
    collection = parser.parse ";PW[Dosaku]", false
    expect(collection.root.children[0].pw).to eq "Dosaku"
  end

  it "should parse a node with two properties" do
    collection = parser.parse ";PB[Aldric]PW[Bob]", false
    expect(collection.root.children[0].pb).to eq "Aldric"
    expect(collection.root.children[0].pw).to eq "Bob"
  end

  it "should apparently ignore line breaks in the middle of a property name -- is this right?" do
    collection = parser.parse ";P\nB[Aldric]P\n\n\nW[Bob]", false
    expect(collection.root.children[0].pb).to eq "Aldric"
    expect(collection.root.children[0].pw).to eq "Bob"
  end

  it "should parse two nodes with one property each" do
    collection = parser.parse ";PB[Aldric];PW[Bob]", false
    node = collection.root.children[0]
    expect(node.pb).to eq "Aldric"
    expect(node.children[0].pw).to eq "Bob"
  end

  it "should parse a tree with a single branch" do
    collection = parser.parse "(;FF[4]PW[Aldric]PB[Bob];B[qq])"
    node = collection.root.children[0]
    expect(node.pb).to eq "Bob"
    expect(node.pw).to eq "Aldric"
    expect(node.children[0].b).to eq "qq"
  end

  it "should parse a tree with two branches" do
    collection = parser.parse "(;FF[4](;C[main])(;C[branch]))"
    node = collection.root.children[0]
    expect(node.ff).to eq "4"
    expect(node.children.size).to eq 2
    expect( node.children[0].c).to eq "main"
    expect(node.children[1].c).to eq "branch"
  end

  it "should parse a comment with a \\] inside" do
    collection = parser.parse "(;C[Oh hi\\] there])"
    expect(collection.root.children[0].c).to eq "Oh hi] there"
  end

  it "should parse a multi-property identity well" do
    collection = parser.parse "(;FF[4];AW[bd][cc][qr])"
    expect(collection.root.children[0].children[0].aw).to eq %w(bd cc qr)
  end

  it "should parse multiple trees" do
    collection = parser.parse "(;FF[4]PW[Aldric];AW[dd][cc])(;FF[4]PW[Hi];PB[ad])"
    expect(collection.root.children.size).to eq 2
    expect(collection.root.children[0].children[0].aw).to eq %w(dd cc)
    expect(collection.root.children[1].children[0].pb).to eq "ad"
  end

  it "should not put (; into the identity when separated by line breaks" do
    collection = parser.parse "(;FF[4]\n\n(;B[dd])(;B[da]))"
    game = collection.root.children[0]
    expect(game.children.size).to eq 2
    expect(game.children[0].b).to eq "dd"
    expect( game.children[1].b).to eq "da"
  end

  it "should parse the simplified sample SGF" do
    collection = parser.parse SIMPLIFIED_SAMPLE_SGF
    root = collection.root
    expect(root.children.size).to eq 2
    node = root.children[0].children[0]
    expect(node.ar).to eq %w(aa:sc sa:ac aa:sa aa:ac cd:cj gd:md fh:ij kj:nh)
  end

  it "should parse a file if given a file handler as input" do
    file = File.open 'spec/data/simple.sgf'
    collection = parser.parse file
    game = collection.gametrees.first
    expect(game.white_player).to eq "redrose"
    expect(game.black_player).to eq "tartrate"
  end

  it "should parse a file if given a local path as input" do
    local_path = 'spec/data/simple.sgf'
    collection = parser.parse local_path
    game = collection.gametrees.first
    expect(game.white_player).to eq "redrose"
    expect(game.black_player).to eq "tartrate"
  end

end
