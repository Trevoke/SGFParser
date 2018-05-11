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
      out = []
      out << "komi #{pps['KM']}" if pps['KM']
      out << "boardsize #{pps['SZ']}\nclear_board"
      pps['AB'].each {|pos| out << to_play("B", pos) } if pps['AB']
      out.join("\n")
    elsif pps.size > 1 || (pps.keys != ["B"] && pps.keys != ["W"])
      ""
    else
      to_play(pps.keys.first, pps.values.first)
    end
  end

  def to_play(color, pos)
    if pos == ""
      gtp_pos = "pass"
    else
      pos = pos.bytes
      x = (pos[0] > 104 ? pos[0] + 1 : pos[0]).chr.upcase
      y = if @upside_down && @boardsize
        (1 + @boardsize) - (pos[1] - 96)
      else
        pos[1] - 96
      end
      gtp_pos = "#{x}#{y}"
    end
    "play #{color} #{gtp_pos}"
  end

  def write_tree_from(node)
    return unless node
    @sgf << "\n" << gtp_move(node)
    write_tree_from node.children[0]
  end

  def open_branch; end

  def close_branch; end
end
