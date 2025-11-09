# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'SGF Gametree Merging' do
  # Helper method to create game-info properties
  def game_info_properties
    SGF::Gametree::PROPERTIES.values
  end

  describe 'Merging two games with shared opening' do
    context 'when games share the first move then diverge' do
      let(:game1) do
        root = SGF::Node.new(FF: '4', GM: '1', SZ: '19')
        node1 = SGF::Node.new(B: 'pd', PB: 'Player A', PW: 'Player B',
                              BR: '5d', WR: '6d', RE: 'W+3.5')
        node2 = SGF::Node.new(W: 'dp')
        root.add_children(node1)
        node1.add_children(node2)
        SGF::Gametree.new(root)
      end

      let(:game2) do
        root = SGF::Node.new(FF: '4', GM: '1', SZ: '19')
        node1 = SGF::Node.new(B: 'pd', PB: 'Player C', PW: 'Player D',
                              BR: '7d', WR: '8d', RE: 'B+Resign')
        node2 = SGF::Node.new(W: 'cp')
        root.add_children(node1)
        node1.add_children(node2)
        SGF::Gametree.new(root)
      end

      it 'creates a merged tree with shared opening move' do
        merged = SGF::Gametree.merge(game1, game2)

        # Root should have FF, GM, SZ but no game-info
        expect(merged.root['FF']).to eq '4'
        expect(merged.root['GM']).to eq '1'
        expect(merged.root['SZ']).to eq '19'
        expect(merged.root['PB']).to be_nil
        expect(merged.root['PW']).to be_nil
      end

      it 'stores shared opening move (B[pd]) without game-info' do
        merged = SGF::Gametree.merge(game1, game2)

        first_move = merged.root.children[0]
        expect(first_move['B']).to eq 'pd'
        expect(first_move['PB']).to be_nil
        expect(first_move['PW']).to be_nil
      end

      it 'creates two variations at the divergence point' do
        merged = SGF::Gametree.merge(game1, game2)

        first_move = merged.root.children[0]
        expect(first_move.children.size).to eq 2
      end

      it 'places game-info at the divergence nodes' do
        merged = SGF::Gametree.merge(game1, game2)

        first_move = merged.root.children[0]
        variations = first_move.children

        # First variation: W[dp] with game1's info
        var1 = variations.find { |n| n['W'] == 'dp' }
        expect(var1).not_to be_nil
        expect(var1['PB']).to eq 'Player A'
        expect(var1['PW']).to eq 'Player B'
        expect(var1['BR']).to eq '5d'
        expect(var1['WR']).to eq '6d'
        expect(var1['RE']).to eq 'W+3.5'

        # Second variation: W[cp] with game2's info
        var2 = variations.find { |n| n['W'] == 'cp' }
        expect(var2).not_to be_nil
        expect(var2['PB']).to eq 'Player C'
        expect(var2['PW']).to eq 'Player D'
        expect(var2['BR']).to eq '7d'
        expect(var2['WR']).to eq '8d'
        expect(var2['RE']).to eq 'B+Resign'
      end

      it 'preserves the move property along with game-info' do
        merged = SGF::Gametree.merge(game1, game2)

        first_move = merged.root.children[0]
        variations = first_move.children

        # Both variations should still have their move properties
        expect(variations.any? { |n| n['W'] == 'dp' }).to be true
        expect(variations.any? { |n| n['W'] == 'cp' }).to be true
      end
    end

    context 'when games share multiple moves before diverging' do
      let(:game1) do
        root = SGF::Node.new(FF: '4', GM: '1', SZ: '19')
        n1 = SGF::Node.new(B: 'pd')
        n2 = SGF::Node.new(W: 'dp')
        n3 = SGF::Node.new(B: 'pp', PB: 'Alice', PW: 'Bob', RE: 'B+5.5')
        n4 = SGF::Node.new(W: 'dd')
        root.add_children(n1)
        n1.add_children(n2)
        n2.add_children(n3)
        n3.add_children(n4)
        SGF::Gametree.new(root)
      end

      let(:game2) do
        root = SGF::Node.new(FF: '4', GM: '1', SZ: '19')
        n1 = SGF::Node.new(B: 'pd')
        n2 = SGF::Node.new(W: 'dp')
        n3 = SGF::Node.new(B: 'pp', PB: 'Charlie', PW: 'Dana', RE: 'W+2.5')
        n4 = SGF::Node.new(W: 'cd')
        root.add_children(n1)
        n1.add_children(n2)
        n2.add_children(n3)
        n3.add_children(n4)
        SGF::Gametree.new(root)
      end

      it 'shares the common opening sequence' do
        merged = SGF::Gametree.merge(game1, game2)

        # Navigate through shared moves
        n1 = merged.root.children[0]
        expect(n1['B']).to eq 'pd'
        expect(n1.children.size).to eq 1  # Only one continuation

        n2 = n1.children[0]
        expect(n2['W']).to eq 'dp'
        expect(n2.children.size).to eq 1  # Still only one continuation

        n3 = n2.children[0]
        expect(n3['B']).to eq 'pp'
        expect(n3.children.size).to eq 2  # Now we have variations
      end

      it 'does not place game-info in shared moves' do
        merged = SGF::Gametree.merge(game1, game2)

        n1 = merged.root.children[0]
        n2 = n1.children[0]
        n3 = n2.children[0]

        # Shared moves should have no game-info
        expect(n1['PB']).to be_nil
        expect(n2['PB']).to be_nil
        expect(n3['PB']).to be_nil
      end

      it 'places game-info at the divergence point' do
        merged = SGF::Gametree.merge(game1, game2)

        # Navigate to divergence
        n3 = merged.root.children[0].children[0].children[0]
        variations = n3.children

        var1 = variations.find { |n| n['W'] == 'dd' }
        expect(var1['PB']).to eq 'Alice'
        expect(var1['PW']).to eq 'Bob'
        expect(var1['RE']).to eq 'B+5.5'

        var2 = variations.find { |n| n['W'] == 'cd' }
        expect(var2['PB']).to eq 'Charlie'
        expect(var2['PW']).to eq 'Dana'
        expect(var2['RE']).to eq 'W+2.5'
      end
    end
  end

  describe 'Merging games that diverge immediately' do
    let(:game1) do
      root = SGF::Node.new(FF: '4', GM: '1', SZ: '19')
      node = SGF::Node.new(B: 'pd', PB: 'Player 1', PW: 'Player 2', RE: 'B+10')
      root.add_children(node)
      SGF::Gametree.new(root)
    end

    let(:game2) do
      root = SGF::Node.new(FF: '4', GM: '1', SZ: '19')
      node = SGF::Node.new(B: 'dd', PB: 'Player 3', PW: 'Player 4', RE: 'W+5')
      root.add_children(node)
      SGF::Gametree.new(root)
    end

    it 'creates immediate variations from root' do
      merged = SGF::Gametree.merge(game1, game2)

      expect(merged.root.children.size).to eq 2
    end

    it 'places game-info in the first move nodes' do
      merged = SGF::Gametree.merge(game1, game2)

      variations = merged.root.children

      var1 = variations.find { |n| n['B'] == 'pd' }
      expect(var1['PB']).to eq 'Player 1'
      expect(var1['PW']).to eq 'Player 2'
      expect(var1['RE']).to eq 'B+10'

      var2 = variations.find { |n| n['B'] == 'dd' }
      expect(var2['PB']).to eq 'Player 3'
      expect(var2['PW']).to eq 'Player 4'
      expect(var2['RE']).to eq 'W+5'
    end

    it 'keeps root properties in root' do
      merged = SGF::Gametree.merge(game1, game2)

      expect(merged.root['FF']).to eq '4'
      expect(merged.root['GM']).to eq '1'
      expect(merged.root['SZ']).to eq '19'
    end
  end

  describe 'Merging three or more games with nested divergences' do
    # Recreate the FF4 example structure:
    # All games: B[pd]
    # Games 1-2: diverge at W (dp vs cp)
    # Games 3-4: share W[ep], B[pp], then diverge at W (ed vs cd)

    let(:game1) do
      root = SGF::Node.new(FF: '4', GM: '1', SZ: '19')
      n1 = SGF::Node.new(B: 'pd')
      n2 = SGF::Node.new(W: 'dp', PB: 'B. Lack', PW: 'W. Hite',
                         BR: '5d', WR: '6d', RO: '2', RE: 'W+3.5',
                         PC: 'London', EV: 'Go Congress')
      root.add_children(n1)
      n1.add_children(n2)
      SGF::Gametree.new(root)
    end

    let(:game2) do
      root = SGF::Node.new(FF: '4', GM: '1', SZ: '19')
      n1 = SGF::Node.new(B: 'pd')
      n2 = SGF::Node.new(W: 'cp', PB: 'B. Lack', PW: 'T. Suji',
                         BR: '5d', WR: '7d', RO: '1', RE: 'W+Resign',
                         PC: 'London', EV: 'Go Congress')
      root.add_children(n1)
      n1.add_children(n2)
      SGF::Gametree.new(root)
    end

    let(:game3) do
      root = SGF::Node.new(FF: '4', GM: '1', SZ: '19')
      n1 = SGF::Node.new(B: 'pd')
      n2 = SGF::Node.new(W: 'ep')
      n3 = SGF::Node.new(B: 'pp')
      n4 = SGF::Node.new(W: 'ed', PB: 'B. Lack', PW: 'S. Abaki',
                         BR: '5d', WR: '1d', RO: '3', RE: 'B+63.5',
                         PC: 'London', EV: 'Go Congress')
      root.add_children(n1)
      n1.add_children(n2)
      n2.add_children(n3)
      n3.add_children(n4)
      SGF::Gametree.new(root)
    end

    let(:game4) do
      root = SGF::Node.new(FF: '4', GM: '1', SZ: '19')
      n1 = SGF::Node.new(B: 'pd')
      n2 = SGF::Node.new(W: 'ep')
      n3 = SGF::Node.new(B: 'pp')
      n4 = SGF::Node.new(W: 'cd', PB: 'B. Lack', PW: 'A. Tari',
                         BR: '5d', WR: '12k', RO: '4', RE: 'B+R',
                         KM: '-59.5', PC: 'London', EV: 'Go Congress')
      root.add_children(n1)
      n1.add_children(n2)
      n2.add_children(n3)
      n3.add_children(n4)
      SGF::Gametree.new(root)
    end

    it 'creates the correct tree structure matching FF4 example' do
      merged = SGF::Gametree.merge(game1, game2, game3, game4)

      # First move is shared by all
      first_move = merged.root.children[0]
      expect(first_move['B']).to eq 'pd'
      expect(first_move.children.size).to eq 3  # Three branches
    end

    it 'creates three branches at first divergence' do
      merged = SGF::Gametree.merge(game1, game2, game3, game4)

      first_move = merged.root.children[0]
      branches = first_move.children

      # Should have W[dp], W[cp], and W[ep]
      expect(branches.map { |n| n['W'] }.sort).to eq ['cp', 'dp', 'ep']
    end

    it 'places game-info correctly for games 1 and 2' do
      merged = SGF::Gametree.merge(game1, game2, game3, game4)

      first_move = merged.root.children[0]
      branches = first_move.children

      # Game 1: W[dp]
      var_dp = branches.find { |n| n['W'] == 'dp' }
      expect(var_dp['PW']).to eq 'W. Hite'
      expect(var_dp['RO']).to eq '2'

      # Game 2: W[cp]
      var_cp = branches.find { |n| n['W'] == 'cp' }
      expect(var_cp['PW']).to eq 'T. Suji'
      expect(var_cp['RO']).to eq '1'
    end

    it 'creates nested structure for games 3 and 4' do
      merged = SGF::Gametree.merge(game1, game2, game3, game4)

      first_move = merged.root.children[0]
      ep_branch = first_move.children.find { |n| n['W'] == 'ep' }

      # W[ep] should have no game-info (shared by games 3 and 4)
      expect(ep_branch['PB']).to be_nil
      expect(ep_branch['PW']).to be_nil

      # Should have one child: B[pp]
      expect(ep_branch.children.size).to eq 1
      pp_move = ep_branch.children[0]
      expect(pp_move['B']).to eq 'pp'
      expect(pp_move['PB']).to be_nil  # Still shared

      # B[pp] should have two children where game-info appears
      expect(pp_move.children.size).to eq 2
    end

    it 'places game-info correctly for games 3 and 4 at their divergence' do
      merged = SGF::Gametree.merge(game1, game2, game3, game4)

      # Navigate to the nested divergence
      first_move = merged.root.children[0]
      ep_branch = first_move.children.find { |n| n['W'] == 'ep' }
      pp_move = ep_branch.children[0]
      final_variations = pp_move.children

      # Game 3: W[ed]
      var_ed = final_variations.find { |n| n['W'] == 'ed' }
      expect(var_ed['PW']).to eq 'S. Abaki'
      expect(var_ed['WR']).to eq '1d'
      expect(var_ed['RO']).to eq '3'
      expect(var_ed['RE']).to eq 'B+63.5'

      # Game 4: W[cd]
      var_cd = final_variations.find { |n| n['W'] == 'cd' }
      expect(var_cd['PW']).to eq 'A. Tari'
      expect(var_cd['WR']).to eq '12k'
      expect(var_cd['RO']).to eq '4'
      expect(var_cd['KM']).to eq '-59.5'
    end

    it 'ensures only one game-info node per path' do
      merged = SGF::Gametree.merge(game1, game2, game3, game4)

      # For each path from root to leaf, count game-info nodes
      game_info_props = game_info_properties

      # Path to game 1 (dp branch)
      path1 = [merged.root, merged.root.children[0],
               merged.root.children[0].children.find { |n| n['W'] == 'dp' }]
      game_info_count1 = path1.count { |node|
        game_info_props.any? { |prop| node[prop] }
      }
      expect(game_info_count1).to eq 1

      # Path to game 3 (ep -> pp -> ed branch)
      first_move = merged.root.children[0]
      ep_branch = first_move.children.find { |n| n['W'] == 'ep' }
      pp_move = ep_branch.children[0]
      ed_move = pp_move.children.find { |n| n['W'] == 'ed' }

      path3 = [merged.root, first_move, ep_branch, pp_move, ed_move]
      game_info_count3 = path3.count { |node|
        game_info_props.any? { |prop| node[prop] }
      }
      expect(game_info_count3).to eq 1
    end
  end

  describe 'Game-info property handling' do
    it 'moves all game-info properties together' do
      game1 = create_game_with_properties(
        moves: [{ B: 'pd' }],
        game_info: { PB: 'Alice', PW: 'Bob', BR: '5d', WR: '6d',
                     DT: '2024-01-01', EV: 'Tournament', PC: 'Tokyo',
                     RO: '1', RE: 'B+10', KM: '6.5', HA: '0' }
      )

      game2 = create_game_with_properties(
        moves: [{ B: 'dd' }],
        game_info: { PB: 'Charlie', PW: 'Dana', BR: '7d', WR: '8d',
                     DT: '2024-01-02', EV: 'Tournament', PC: 'Osaka',
                     RO: '2', RE: 'W+5', KM: '6.5', HA: '0' }
      )

      merged = SGF::Gametree.merge(game1, game2)
      variations = merged.root.children

      # All game-info should move together
      var1 = variations.find { |n| n['B'] == 'pd' }
      expect(var1['PB']).to eq 'Alice'
      expect(var1['DT']).to eq '2024-01-01'
      expect(var1['EV']).to eq 'Tournament'
      expect(var1['RO']).to eq '1'
      expect(var1['KM']).to eq '6.5'
    end

    it 'keeps root properties (FF, GM, SZ, etc.) at root' do
      game1 = create_game_with_properties(
        root_props: { FF: '4', GM: '1', SZ: '19', AP: 'TestApp:1.0', CA: 'UTF-8' },
        moves: [{ B: 'pd', PB: 'Alice', PW: 'Bob' }]
      )

      game2 = create_game_with_properties(
        root_props: { FF: '4', GM: '1', SZ: '19', AP: 'TestApp:1.0', CA: 'UTF-8' },
        moves: [{ B: 'dd', PB: 'Charlie', PW: 'Dana' }]
      )

      merged = SGF::Gametree.merge(game1, game2)

      # Root properties stay at root
      expect(merged.root['FF']).to eq '4'
      expect(merged.root['GM']).to eq '1'
      expect(merged.root['SZ']).to eq '19'
      expect(merged.root['AP']).to eq 'TestApp:1.0'
      expect(merged.root['CA']).to eq 'UTF-8'

      # But not game-info
      expect(merged.root['PB']).to be_nil
      expect(merged.root['PW']).to be_nil
    end

    it 'preserves non-game-info properties in their original locations' do
      root = SGF::Node.new(FF: '4', GM: '1', SZ: '19')
      n1 = SGF::Node.new(B: 'pd', C: 'Good move!', PB: 'Alice', PW: 'Bob')
      n2 = SGF::Node.new(W: 'dp', C: 'Standard response')
      root.add_children(n1)
      n1.add_children(n2)
      game1 = SGF::Gametree.new(root)

      root2 = SGF::Node.new(FF: '4', GM: '1', SZ: '19')
      n1b = SGF::Node.new(B: 'pd', C: 'Good move!', PB: 'Charlie', PW: 'Dana')
      n2b = SGF::Node.new(W: 'cp', C: 'Alternative')
      root2.add_children(n1b)
      n1b.add_children(n2b)
      game2 = SGF::Gametree.new(root2)

      merged = SGF::Gametree.merge(game1, game2)

      # Comment on shared move should be preserved
      first_move = merged.root.children[0]
      expect(first_move['C']).to eq 'Good move!'

      # Comments on diverging moves should be preserved
      variations = first_move.children
      var_dp = variations.find { |n| n['W'] == 'dp' }
      var_cp = variations.find { |n| n['W'] == 'cp' }

      expect(var_dp['C']).to eq 'Standard response'
      expect(var_cp['C']).to eq 'Alternative'
    end
  end

  describe 'Edge cases and validation' do
    it 'handles games with no game-info properties' do
      game1 = create_simple_game([{ B: 'pd' }, { W: 'dp' }])
      game2 = create_simple_game([{ B: 'pd' }, { W: 'cp' }])

      merged = SGF::Gametree.merge(game1, game2)

      # Should still merge correctly
      first_move = merged.root.children[0]
      expect(first_move.children.size).to eq 2
    end

    it 'handles games where only some have game-info' do
      game1 = create_game_with_properties(
        moves: [{ B: 'pd' }, { W: 'dp', PB: 'Alice', PW: 'Bob' }]
      )
      game2 = create_simple_game([{ B: 'pd' }, { W: 'cp' }])

      merged = SGF::Gametree.merge(game1, game2)

      first_move = merged.root.children[0]
      var_dp = first_move.children.find { |n| n['W'] == 'dp' }
      var_cp = first_move.children.find { |n| n['W'] == 'cp' }

      expect(var_dp['PB']).to eq 'Alice'
      expect(var_cp['PB']).to be_nil
    end

    it 'handles identical games appropriately' do
      game1 = create_game_with_properties(
        moves: [{ B: 'pd' }, { W: 'dp' }],
        game_info: { PB: 'Alice', PW: 'Bob' }
      )
      game2 = create_game_with_properties(
        moves: [{ B: 'pd' }, { W: 'dp' }],
        game_info: { PB: 'Charlie', PW: 'Dana' }
      )

      # Identical move sequences but different game-info
      # This is an edge case - the spec doesn't clearly define this
      # One approach: merge them as variations at the last move
      # Another approach: raise an error
      # Let's test for raising an error for now
      expect {
        SGF::Gametree.merge(game1, game2)
      }.to raise_error(SGF::MergeError, /identical move sequences/)
    end

    it 'validates that merged tree has only one game-info node per path' do
      # This test verifies the constraint is maintained
      game1 = create_game_with_properties(
        moves: [{ B: 'pd' }, { W: 'dp' }],
        game_info: { PB: 'Alice', PW: 'Bob' }
      )
      game2 = create_game_with_properties(
        moves: [{ B: 'pd' }, { W: 'cp' }],
        game_info: { PB: 'Charlie', PW: 'Dana' }
      )

      merged = SGF::Gametree.merge(game1, game2)

      # Validate each path
      first_move = merged.root.children[0]
      first_move.children.each do |variation|
        path = []
        node = merged.root
        while node
          path << node
          break if node == variation
          node = node.children[0] if node.children.size == 1
        end

        game_info_nodes = path.select { |n|
          game_info_properties.any? { |prop| n[prop] }
        }
        expect(game_info_nodes.size).to be <= 1
      end
    end

    it 'handles empty games' do
      empty_game = SGF::Gametree.new(SGF::Node.new(FF: '4', GM: '1', SZ: '19'))
      game_with_moves = create_simple_game([{ B: 'pd' }])

      merged = SGF::Gametree.merge(empty_game, game_with_moves)

      # Should handle gracefully, perhaps by ignoring empty game
      expect(merged.root.children.size).to be >= 1
    end
  end

  # Helper methods
  def create_simple_game(moves)
    root = SGF::Node.new(FF: '4', GM: '1', SZ: '19')
    parent = root
    moves.each do |move_hash|
      node = SGF::Node.new(move_hash)
      parent.add_children(node)
      parent = node
    end
    SGF::Gametree.new(root)
  end

  def create_game_with_properties(root_props: {}, moves: [], game_info: {})
    default_root_props = { FF: '4', GM: '1', SZ: '19' }
    root = SGF::Node.new(default_root_props.merge(root_props))

    parent = root
    moves.each_with_index do |move_hash, idx|
      # Add game-info to the first move if provided
      if idx == 0 && game_info.any?
        move_hash = move_hash.merge(game_info)
      end
      node = SGF::Node.new(move_hash)
      parent.add_children(node)
      parent = node
    end

    SGF::Gametree.new(root)
  end
end
