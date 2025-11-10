require 'spec_helper'

RSpec.describe SGF::GameTreeMerger do
  describe '#merge' do
    context 'when games have no common moves' do
      it 'creates variations from the root' do
        # Game 1: root -> B[aa]
        root1 = SGF::Node.new
        move1 = SGF::Node.new
        move1.add_properties('B' => 'aa')
        root1.add_children(move1)
        game1 = SGF::Gametree.new(root1)

        # Game 2: root -> B[bb]
        root2 = SGF::Node.new
        move2 = SGF::Node.new
        move2.add_properties('B' => 'bb')
        root2.add_children(move2)
        game2 = SGF::Gametree.new(root2)

        # Merge
        merger = SGF::GameTreeMerger.new
        result = merger.merge(game1, game2)

        # Expectations: root should have 2 children (variations)
        expect(result.root.children.size).to eq(2)
        expect(result.root.children[0].properties['B']).to eq('aa')
        expect(result.root.children[1].properties['B']).to eq('bb')
      end
    end

    context 'when games share common opening moves' do
      it 'shares the common sequence and branches at divergence' do
        # Game 1: root -> B[aa] -> W[bb] -> B[cc]
        root1 = SGF::Node.new
        move1 = SGF::Node.new
        move1.add_properties('B' => 'aa')
        move2 = SGF::Node.new
        move2.add_properties('W' => 'bb')
        move3 = SGF::Node.new
        move3.add_properties('B' => 'cc')
        root1.add_children(move1)
        move1.add_children(move2)
        move2.add_children(move3)
        game1 = SGF::Gametree.new(root1)

        # Game 2: root -> B[aa] -> W[bb] -> B[dd]
        root2 = SGF::Node.new
        move1_g2 = SGF::Node.new
        move1_g2.add_properties('B' => 'aa')
        move2_g2 = SGF::Node.new
        move2_g2.add_properties('W' => 'bb')
        move3_g2 = SGF::Node.new
        move3_g2.add_properties('B' => 'dd')
        root2.add_children(move1_g2)
        move1_g2.add_children(move2_g2)
        move2_g2.add_children(move3_g2)
        game2 = SGF::Gametree.new(root2)

        # Merge
        merger = SGF::GameTreeMerger.new
        result = merger.merge(game1, game2)

        # Expectations: Should have shared sequence up to W[bb]
        # Then branch at B[cc] vs B[dd]
        expect(result.root.children.size).to eq(1)
        first_move = result.root.children[0]
        expect(first_move.properties['B']).to eq('aa')

        second_move = first_move.children[0]
        expect(second_move.properties['W']).to eq('bb')

        # At this point, should have 2 variations
        expect(second_move.children.size).to eq(2)
        expect(second_move.children[0].properties['B']).to eq('cc')
        expect(second_move.children[1].properties['B']).to eq('dd')
      end
    end

    context 'when games are identical' do
      it 'results in a single path with no variations' do
        # Game 1: root -> B[aa] -> W[bb]
        root1 = SGF::Node.new
        move1 = SGF::Node.new
        move1.add_properties('B' => 'aa')
        move2 = SGF::Node.new
        move2.add_properties('W' => 'bb')
        root1.add_children(move1)
        move1.add_children(move2)
        game1 = SGF::Gametree.new(root1)

        # Game 2: root -> B[aa] -> W[bb] (identical)
        root2 = SGF::Node.new
        move1_g2 = SGF::Node.new
        move1_g2.add_properties('B' => 'aa')
        move2_g2 = SGF::Node.new
        move2_g2.add_properties('W' => 'bb')
        root2.add_children(move1_g2)
        move1_g2.add_children(move2_g2)
        game2 = SGF::Gametree.new(root2)

        # Merge
        merger = SGF::GameTreeMerger.new
        result = merger.merge(game1, game2)

        # Should have single path, no variations
        expect(result.root.children.size).to eq(1)
        first_move = result.root.children[0]
        expect(first_move.properties['B']).to eq('aa')
        expect(first_move.children.size).to eq(1)

        second_move = first_move.children[0]
        expect(second_move.properties['W']).to eq('bb')
        expect(second_move.children.size).to eq(0) # No variations
      end
    end

    context 'when one game is a prefix of another' do
      it 'continues the longer game as a single path' do
        # Game 1 (shorter): root -> B[aa] -> W[bb]
        root1 = SGF::Node.new
        move1 = SGF::Node.new
        move1.add_properties('B' => 'aa')
        move2 = SGF::Node.new
        move2.add_properties('W' => 'bb')
        root1.add_children(move1)
        move1.add_children(move2)
        game1 = SGF::Gametree.new(root1)

        # Game 2 (longer): root -> B[aa] -> W[bb] -> B[cc] -> W[dd]
        root2 = SGF::Node.new
        move1_g2 = SGF::Node.new
        move1_g2.add_properties('B' => 'aa')
        move2_g2 = SGF::Node.new
        move2_g2.add_properties('W' => 'bb')
        move3_g2 = SGF::Node.new
        move3_g2.add_properties('B' => 'cc')
        move4_g2 = SGF::Node.new
        move4_g2.add_properties('W' => 'dd')
        root2.add_children(move1_g2)
        move1_g2.add_children(move2_g2)
        move2_g2.add_children(move3_g2)
        move3_g2.add_children(move4_g2)
        game2 = SGF::Gametree.new(root2)

        # Merge
        merger = SGF::GameTreeMerger.new
        result = merger.merge(game1, game2)

        # Should have the longer path
        expect(result.root.children.size).to eq(1)

        current = result.root.children[0]
        expect(current.properties['B']).to eq('aa')

        current = current.children[0]
        expect(current.properties['W']).to eq('bb')

        current = current.children[0]
        expect(current.properties['B']).to eq('cc')

        current = current.children[0]
        expect(current.properties['W']).to eq('dd')
        expect(current.children.size).to eq(0)
      end
    end

    context 'when games have existing variations' do
      it 'preserves existing variations in the merged tree' do
        # Game 1: root -> B[aa] -> W[bb] with variation at W
        #   Main: W[bb] -> B[cc]
        #   Var:  W[bb] -> B[ee]
        root1 = SGF::Node.new
        move1 = SGF::Node.new
        move1.add_properties('B' => 'aa')
        move2 = SGF::Node.new
        move2.add_properties('W' => 'bb')
        move3_main = SGF::Node.new
        move3_main.add_properties('B' => 'cc')
        move3_var = SGF::Node.new
        move3_var.add_properties('B' => 'ee')

        root1.add_children(move1)
        move1.add_children(move2)
        move2.add_children(move3_main, move3_var)  # Two variations
        game1 = SGF::Gametree.new(root1)

        # Game 2: root -> B[aa] -> W[bb] -> B[dd]
        root2 = SGF::Node.new
        move1_g2 = SGF::Node.new
        move1_g2.add_properties('B' => 'aa')
        move2_g2 = SGF::Node.new
        move2_g2.add_properties('W' => 'bb')
        move3_g2 = SGF::Node.new
        move3_g2.add_properties('B' => 'dd')
        root2.add_children(move1_g2)
        move1_g2.add_children(move2_g2)
        move2_g2.add_children(move3_g2)
        game2 = SGF::Gametree.new(root2)

        # Merge
        merger = SGF::GameTreeMerger.new
        result = merger.merge(game1, game2)

        # Navigate to the divergence point
        current = result.root.children[0]
        expect(current.properties['B']).to eq('aa')

        current = current.children[0]
        expect(current.properties['W']).to eq('bb')

        # Should have 3 variations now: cc (main), ee (var from game1), dd (from game2)
        expect(current.children.size).to eq(3)
        moves = current.children.map { |child| child.properties['B'] }.sort
        expect(moves).to eq(['cc', 'dd', 'ee'])
      end
    end

    context 'when games have game-info properties' do
      it 'places game-info at the first distinguishable node' do
        # Game 1: root -> B[aa] -> W[bb]
        # Game-info: PB: "Player1", PW: "Player2"
        root1 = SGF::Node.new
        root1.add_properties('PB' => 'Player1', 'PW' => 'Player2', 'RE' => '1-0')
        move1 = SGF::Node.new
        move1.add_properties('B' => 'aa')
        move2 = SGF::Node.new
        move2.add_properties('W' => 'bb')
        root1.add_children(move1)
        move1.add_children(move2)
        game1 = SGF::Gametree.new(root1)

        # Game 2: root -> B[aa] -> W[cc]
        # Game-info: PB: "Player3", PW: "Player4"
        root2 = SGF::Node.new
        root2.add_properties('PB' => 'Player3', 'PW' => 'Player4', 'RE' => '0-1')
        move1_g2 = SGF::Node.new
        move1_g2.add_properties('B' => 'aa')
        move2_g2 = SGF::Node.new
        move2_g2.add_properties('W' => 'cc')
        root2.add_children(move1_g2)
        move1_g2.add_children(move2_g2)
        game2 = SGF::Gametree.new(root2)

        # Merge
        merger = SGF::GameTreeMerger.new
        result = merger.merge(game1, game2)

        # Root and first move (B[aa]) should not have game-info
        # Game-info should be at the divergence point (W[bb] vs W[cc])
        expect(result.root.properties['PB']).to be_nil

        first_move = result.root.children[0]
        expect(first_move.properties['B']).to eq('aa')
        expect(first_move.properties['PB']).to be_nil

        # At divergence point, each variation should have its game-info
        expect(first_move.children.size).to eq(2)

        var1 = first_move.children.find { |n| n.properties['W'] == 'bb' }
        var2 = first_move.children.find { |n| n.properties['W'] == 'cc' }

        expect(var1.properties['PB']).to eq('Player1')
        expect(var1.properties['PW']).to eq('Player2')
        expect(var1.properties['RE']).to eq('1-0')

        expect(var2.properties['PB']).to eq('Player3')
        expect(var2.properties['PW']).to eq('Player4')
        expect(var2.properties['RE']).to eq('0-1')
      end
    end

    context 'when merging empty games' do
      it 'handles games with no moves gracefully' do
        # Game 1: just root, no moves
        root1 = SGF::Node.new
        root1.add_properties('PB' => 'Player1', 'PW' => 'Player2')
        game1 = SGF::Gametree.new(root1)

        # Game 2: just root, no moves
        root2 = SGF::Node.new
        root2.add_properties('PB' => 'Player3', 'PW' => 'Player4')
        game2 = SGF::Gametree.new(root2)

        # Merge
        merger = SGF::GameTreeMerger.new
        result = merger.merge(game1, game2)

        # Should have a root with no children (since there are no moves)
        expect(result.root.children.size).to eq(0)
        expect(result.root.properties['PB']).to be_nil # No game-info without moves
      end
    end

    context 'convenience method on Gametree' do
      it 'allows calling merge directly on a gametree instance' do
        # Game 1: root -> B[aa] -> W[bb]
        root1 = SGF::Node.new
        move1 = SGF::Node.new
        move1.add_properties('B' => 'aa')
        move2 = SGF::Node.new
        move2.add_properties('W' => 'bb')
        root1.add_children(move1)
        move1.add_children(move2)
        game1 = SGF::Gametree.new(root1)

        # Game 2: root -> B[aa] -> W[cc]
        root2 = SGF::Node.new
        move1_g2 = SGF::Node.new
        move1_g2.add_properties('B' => 'aa')
        move2_g2 = SGF::Node.new
        move2_g2.add_properties('W' => 'cc')
        root2.add_children(move1_g2)
        move1_g2.add_children(move2_g2)
        game2 = SGF::Gametree.new(root2)

        # Merge using convenience method
        result = game1.merge(game2)

        # Should have shared sequence up to B[aa]
        expect(result.root.children.size).to eq(1)
        first_move = result.root.children[0]
        expect(first_move.properties['B']).to eq('aa')

        # Then branch at W[bb] vs W[cc]
        expect(first_move.children.size).to eq(2)
        expect(first_move.children[0].properties['W']).to eq('bb')
        expect(first_move.children[1].properties['W']).to eq('cc')
      end
    end
  end
end
