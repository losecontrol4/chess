require_relative 'piece'


class Rook < Piece

  attr_reader :token

  def initialize(is_white, curr_location)
    super
    @token = @is_white ? '♖' : '♜'
  end

 def update_possible_moves(board)
  @possible_moves = get_possible_vh_moves(board) #from module
 end
end

