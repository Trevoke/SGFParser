# frozen_string_literal: true

module SGF
  # Merges multiple GameTrees into a single tree with variations
  class GameTreeMerger
    # Game-info property identities from the SGF specification
    GAME_INFO_PROPERTIES = Gametree::PROPERTIES.values.freeze

    # Merges two gametrees into a single tree
    # @param game1 [Gametree] First game to merge
    # @param game2 [Gametree] Second game to merge
    # @return [Gametree] Merged gametree with variations
    def merge(game1, game2)
      merged_root = Node.new

      # Extract game-info from roots
      game_info1 = extract_game_info(game1.root)
      game_info2 = extract_game_info(game2.root)

      # Find common sequence from both games
      path1 = get_main_path(game1.root)
      path2 = get_main_path(game2.root)

      # Merge the common sequence
      merge_paths(merged_root, path1, path2, game_info1, game_info2)

      Gametree.new(merged_root)
    end

    private

    # Extract game-info properties from a node
    def extract_game_info(node)
      game_info = {}
      node.properties.each do |identity, property|
        game_info[identity] = property if GAME_INFO_PROPERTIES.include?(identity)
      end
      game_info
    end

    # Get the main path (first child at each level) from a node
    def get_main_path(node)
      path = []
      current = node.children[0]
      while current
        path << current
        current = current.children[0]
      end
      path
    end

    # Merge two paths into the merged tree
    def merge_paths(merged_root, path1, path2, game_info1, game_info2)
      current_merged = merged_root
      i = 0

      # Find common sequence
      while i < path1.length && i < path2.length && nodes_equal?(path1[i], path2[i])
        # Clone the common node and add to merged tree
        common_node = clone_node(path1[i])
        current_merged.add_children(common_node)
        current_merged = common_node
        i += 1
      end

      # Add divergent paths as variations
      # If path1 has remaining nodes, clone the entire subtree including all variations
      if i < path1.length
        original_node = path1[i]
        # Clone the main line
        divergent_node1 = clone_subtree(original_node)
        # Add game-info to the first distinguishable node
        divergent_node1.add_properties(game_info1) unless game_info1.empty?
        current_merged.add_children(divergent_node1)

        # Clone any sibling variations (other children of the parent node)
        # We need to get all children from the original parent, not just the main line
        if i > 0
          original_parent = path1[i - 1]
          original_parent.children.each do |sibling|
            next if sibling == original_node # Skip the main line we already cloned

            sibling_clone = clone_subtree(sibling)
            # Sibling variations from game1 also get game1's info
            sibling_clone.add_properties(game_info1) unless game_info1.empty?
            current_merged.add_children(sibling_clone)
          end
        end
      end

      if i < path2.length
        divergent_node2 = clone_subtree(path2[i])
        # Add game-info to the first distinguishable node
        divergent_node2.add_properties(game_info2) unless game_info2.empty?
        current_merged.add_children(divergent_node2)
      end
    end

    # Check if two nodes have the same properties (excluding game-info)
    def nodes_equal?(node1, node2)
      props1 = node1.properties.reject { |k, _v| GAME_INFO_PROPERTIES.include?(k) }
      props2 = node2.properties.reject { |k, _v| GAME_INFO_PROPERTIES.include?(k) }
      props1 == props2
    end

    # Clone a node (without children), excluding game-info properties
    def clone_node(node)
      new_node = Node.new
      # Only copy non-game-info properties for common sequence nodes
      non_game_info = node.properties.reject { |k, _v| GAME_INFO_PROPERTIES.include?(k) }
      new_node.add_properties(non_game_info)
      new_node
    end

    # Clone a node and all its descendants
    def clone_subtree(node)
      new_node = clone_node(node)
      node.children.each do |child|
        new_node.add_children(clone_subtree(child))
      end
      new_node
    end
  end
end
