require 'set'

module Moves

 # each function doubles as a way to get a set of possible moves a piece of a certain movement type can make, as well as a way for the king to know
 # if they are in check from an enemy piece of that type (from the king side of things). This double feature is used
 # to optimize checking if the king is in check.

  def get_possible_diagonal_moves(board) #get all possible diagonal moves, like a bishop
    # returns a set of possible moves
    possible_moves = Set.new
    [-1, 1].each do |i|
      [-1, 1].each do |j|
         movement(board, @curr_location, i, j, possible_moves)
         #the movement function does the heavy lifting
      end
    end
    possible_moves
  end

  def get_possible_vh_moves(board) # get all possible moves vertical and horizontal, like a rook. vh = vertical and horizontal
    # returns a set of possible moves
    possible_moves = Set.new
    [-1, 1].each do |i|
         movement(board, @curr_location, i, 0, possible_moves)
         movement(board, @curr_location, 0, i, possible_moves)
          #the movement function does the heavy lifting
      end
    possible_moves
  end

  def get_possible_knight_moves(board)
    possible_moves = Set.new
    [-1, 1].each do |i|
      [-2, 2].each do |j|
        2.times do |index|
          if index == 0
            row = @curr_location[0] + i
            col = @curr_location[1] + j
          else
            row = @curr_location[0] + j
            col = @curr_location[1] + i
          end
          next if row < 0 || row > 7 || col < 0 || col > 7 || !(board[row][col].nil? || board[row][col].is_white != @is_white) 
          if self.is_a?(King) 
              return if @in_check
              @in_check = board[row][col].is_a?(Knight) 
          else
          possible_moves.add([row, col])
          end
      end
      end
    end
    possible_moves
  end

  def get_possible_pawn_moves(board)
    
    factor = is_white ? -1 : 1 #since pawns can only go forward
    row = @curr_location[0]
    col = @curr_location[1]
 

    possible_moves = Set.new
    row = @curr_location[0]
    col = @curr_location[1]
    
    return if self.is_a?(King) && row + factor < 0 || row + factor > 7 #handles the fact that kings can be on the edge, while pawns can't

    possible_moves.add([row + factor, col]) if board[row + factor][col].nil?
    if self.is_a?(Pawn) && !@moved && board[row + factor * 2][col].nil?
        possible_moves.add([row + factor * 2, col])
    end
    
    [-1, 1].each do |i|
      if col + i >= 0  && !board[row + factor][col + i].nil? && board[row + factor][col + i].is_white != @is_white
        # don't need to check above 7 because that will return nil anyways
        if self.is_a?(King)
          return if @in_check
          @in_check = true if board[row + factor][col + i].is_a?(Pawn)
        else
        possible_moves.add([row + factor, col + i])
        end
      end
    end

    #en_passant
    if self.is_a?(Pawn) && @passant != 0
      possible_moves.add([row + factor, col + @passant])
    end
    possible_moves
  end

  def get_possible_king_moves(board)
    #both recieves a possible set for a king and will tell if it is in check from a king
    row = @curr_location[0]
    col = @curr_location[1]
    possible_moves = Set.new
    Array(-1..1).each do |i| 
      Array(-1..1).each do |j| 
        next if i == 0 && j == 0
        next if row + i < 0 || row + i > 7 || col + j < 0 || col + j > 7
        if board[row + i][col + j].nil?
          possible_moves.add([row + i, col + j])
        else
          if board[row + i][col + j].is_white != @is_white
            possible_moves.add([row + i, col + j])
            @in_check = true if board[row + i][col + j].is_a?(King) 
          end
        end
      end
    end
    possible_moves
  end

  def movement(board, curr_cords, i, j, possible_moves) # for use with rook and bishop movement
    return if self.is_a?(King) && @in_check
    row = curr_cords[0] + i
    col = curr_cords[1] + j
    return if row < 0 || row > 7 || col < 0 || col > 7
   
    if board[row][col].nil? 
      possible_moves.add([row, col])
      movement(board, [row, col], i, j, possible_moves) # continue pathing if this pass didn't hit an enemy or border, for kings, only include enemy squares
    else # if this square is occupied by an ally piece, it isn't an option, otherwise it is.
      possible_moves.add([row, col]) unless board[row][col].is_white == @is_white
      if self.is_a?(King) && board[row][col].is_white != @is_white
        is_vh = i == 0 || j == 0
        if is_vh 
            @in_check = board[row][col].is_a?(Queen) || board[row][col].is_a?(Rook)
        else 
            @in_check = board[row][col].is_a?(Queen) || board[row][col].is_a?(Bishop)
        end
        
      end
    end
  end

end