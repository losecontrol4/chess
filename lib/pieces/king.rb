require_relative 'piece'

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
    # this is the most interesting thing I did in this program, and what I spent time planning around before I wrote the code
    # To find if the king is in check, instead of checking every single piece, I only check for the king, giving it the movement
    # of every other piece. All of these functions serve a slightly different purpose when called by a king. 
    # They will change it's in check variable if it runs into a piece that could hit the king.
    @in_check = false
    get_possible_diagonal_moves(board) 
    get_possible_vh_moves(board) unless @in_check 
    get_possible_knight_moves(board) unless @in_check
    get_possible_pawn_moves(board) unless @in_check
    get_possible_king_moves(board) unless @in_check
  end
end

