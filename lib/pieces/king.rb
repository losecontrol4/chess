require_relative 'piece'
# require_relative '../movement_modules/king_like'

class King < Piece
  attr_accessor :in_check
  attr_reader :token, :moved

  def initialize(is_white, curr_location)
    super
    @token = @is_white ? '♔' : '♚'
    @in_check = false
    @moved = false
  end
  
  def update_possible_moves(board)
    @possible_moves = get_possible_king_moves(board) #from module
   end
  
  def move(cords)
    @curr_location = cords
    @moved = true
  end

  def update_in_check(board)
    @in_check = false
    get_possible_diagonal_moves(board) 
    get_possible_vh_moves(board) unless @in_check 
    get_possible_knight_moves(board) unless @in_check
    get_possible_pawn_moves(board) unless @in_check
    get_possible_king_moves(board) unless @in_check
  end
end

