require_relative 'piece'

class Queen < Piece



  attr_reader :token

  def initialize(is_white, curr_location)
    super
    @token = @is_white ? '♕' : '♛'
  end

  def update_possible_moves(board)
    @possible_moves = get_possible_vh_moves(board) + get_possible_diagonal_moves(board)
   # p @possible_moves
  end
end


test = Queen.new(true, [4, 4])
board = Array.new(8) {Array.new(8, nil)}
board[4][6] = Queen.new(true, nil)
board[4][1] = Queen.new(false, nil)
board[3][5] = Queen.new(false, nil)

test.update_possible_moves(board)