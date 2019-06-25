# typed: true
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
      pps['AB']&.each { |pos| out << to_play('B', pos) }
      pps['AW']&.each { |pos| out << to_play('W', pos) }
      out.join("\n")
    elsif pps['B']
      to_play('B', pps['B'])
    elsif pps['W']
      to_play('W', pps['W'])
    else
      ''
    end
  end

  def to_play(color, pos)
    if pos == ''
      gtp_pos = 'pass'
    else
      pos = pos.bytes
      # for some reason, GTP skip the letter `I` in the coordinate.
      # so we +1 we get [A-H+J-T] for 19x19 board
      x = (pos[0] > 104 ? pos[0] + 1 : pos[0]).chr.upcase
      # y coordinate is numerical, substract the ascii value of `a` is giving us the number we want.
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

    @sgf += "\n" unless @sgf.empty?
    @sgf += gtp_move(node)
    write_tree_from node.children[0]
  end

  def open_branch; end

  def close_branch; end
end
