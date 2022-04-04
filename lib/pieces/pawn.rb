require_relative 'piece'
#currently need a way to make moved = true
class Pawn < Piece
  attr_reader :token
  #maybe make it a writer
  attr_writer :passant

  def initialize(is_white, curr_location)
    super
    @token = @is_white ? '♙' : '♟'
    @moved = false
    @passant = 0
  end

  def update_possible_moves(board)
    @possible_moves = get_possible_pawn_moves(board) #from module
  end
  
  def move(cords)
    @curr_location = cords
    @moved = true
  end
end
