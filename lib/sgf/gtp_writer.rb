class SGF::GtpWriter < SGF::Writer

  private

  def gtp_move(node)
    pps = node.properties
    if pps.keys == ["FF"]
      return ""
    elsif pps.size > 1
      if pps['SZ']
        return "boardsize #{pps['SZ']}\nclear_board"
      else
        #raise "i dont know what to do with this node #{node.to_s}, properties.size == #{pps.size}"
        return ""
      end
    elsif pps.keys != ["B"] and pps.keys != ["W"]
      raise "unknown keys found #{pps.keys}"
    end

    if pps.values == [""]
      gtp_pos = "pass"
    else
      pos = pps.values.first.bytes
      if pos.size != 2
        raise "unrecognizable position #{pps.values}"
      end
      x = (pos[0] > 104 ? pos[0]+1 : pos[0]).chr.upcase
      gtp_pos = "#{x}#{pos[1] - 96}"
    end
   "play #{pps.keys.first} #{gtp_pos}"
  end

  def write_tree_from node
    return unless node
    @sgf << "\n" << gtp_move(node)
    write_tree_from node.children[0]
  end

  def open_branch
  end
  def close_branch
  end
end
