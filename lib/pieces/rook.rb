require_relative 'piece'


class Rook < Piece

  attr_reader :token, :moved

  def initialize(is_white, curr_location)
    super
    @token = @is_white ? '♖' : '♜'
    @moved = false
  end

 def update_possible_moves(board)
  @possible_moves = get_possible_vh_moves(board) #from module
 end

 def move(cords)
  @curr_location = cords
  @moved = true
 end
end

