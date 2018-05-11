# frozen_string_literal: true

class SGF::GtpWriter < SGF::Writer
  attr_writer :upside_down

  def initialize
    @upside_down = false
  end

  private

  def gtp_move(node)
    pps = node.properties
    if pps['SZ']
      @boardsize = pps['SZ'].to_i
      return "boardsize #{pps['SZ']}\nclear_board"
    end
    return "" if pps.size > 1 || (pps.keys != ["B"] && pps.keys != ["W"])

    if pps.values == [""]
      gtp_pos = "pass"
    else
      pos = pps.values.first.bytes
      raise "unrecognizable position #{pps.values}" if pos.size != 2
      x = (pos[0] > 104 ? pos[0] + 1 : pos[0]).chr.upcase
      y = if @upside_down && @boardsize
        (1 + @boardsize) - (pos[1] - 96)
      else
        pos[1] - 96
      end
      gtp_pos = "#{x}#{y}"
    end
    "play #{pps.keys.first} #{gtp_pos}"
  end

  def write_tree_from(node)
    return unless node
    @sgf << "\n" << gtp_move(node)
    write_tree_from node.children[0]
  end

  def open_branch; end

  def close_branch; end
end
