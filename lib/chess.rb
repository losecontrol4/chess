Dir[File.join(__dir__, 'pieces', '*.rb')].each { |file| require file }

class Chess
  attr_accessor :board, :white_pieces, :white_king, :black_king, :checkmate

  def initialize(white_p, black_p)
    @board = get_new_board
    @white_pieces = @board[6] + @board[7]
    @black_pieces = @board[0] + @board[1]
    @white_king = @board[7][4]
    @black_king = @board[0][4]
    @player1 = white_p
    @player2 = black_p
    @player1.is_white = true
    @player2.is_white = false
    @checkmate = false

  end



  def play
    puts "Welcomes to chess"
    until @checkmate
      #player1 turn
      puts self
      take_turn(@player1)
      update_checkmate(@player2)
    #---------------------
      next if @checkmate
     # player2 turn
      puts self
      take_turn(@player2)
      update_checkmate(@player1)
    end
  end

  def self.algnot_to_cord(algnot)
    #takes a value in algebraic notation, returns coordinates
    [9 - algnot[1].to_i - 1, (algnot[0].downcase.ord - 97)]
  end
  
  def self.cord_to_algnot(cord)
    #takes coordinates and returns it in algebraic notation
    (cord[1] + 97).chr + (7 - cord[0] + 1).to_s
  end

  def take_turn(player)
    outcome = -1
    while outcome != 0
      move = player.get_move
      outcome = make_move(player.is_white, Chess.algnot_to_cord(move[0..1]), Chess.algnot_to_cord(move[2..3]))
      case outcome
      when 1
        puts "A cordinate you entered is out of bounds"
      when 2
        puts "You need to select your own piece."
      when 3
        puts "That is not a valid move for the piece you selected."
      when 4 
        puts "You cannot put yourself in check."
      end
    end
  end

  def get_new_board
    board = Array.new(8) { Array.new(8, nil) }
    piece_row(false, board[0], 0)
    pawn_row(false, board[1], 1)
    pawn_row(true, board[6], 6)
    piece_row(true, board[7], 7)
    board
  end

  def make_move(is_white, cord1, cord2)
    #returns 0 if move went well
    #returns 1 if either cordinate is out of bounds
    #returns 2 if first cord given doesn't have a piece, or is the enemy's piece
    #returns 3 if the second cord is not a valid move for that piece. 
    #returns 4 if the move would put yourself in check
    (cord1 + cord2).each {|val| return 1 if val < 0 || val > 7}
    piece = @board[cord1[0]][cord1[1]]
    if piece.nil? || piece.is_white != is_white
      return 2
    end
    piece.update_possible_moves(@board)
    
  
    return 3 unless piece.possible_moves.include?(cord2)
    # need to check if the move puts yourself in check
    return 4 if look_ahead_for_check(is_white, cord1, cord2)
    
    unless @board[cord2[0]][cord2[1]].nil?
      @board[cord2[0]][cord2[1]].kill
    end
    piece.move(cord2)
    @board[cord2[0]][cord2[1]] = piece
    @board[cord1[0]][cord1[1]] = nil
    0
  end

  def update_checkmate(player)
    king = player.is_white ? @white_king : @black_king
    king.update_in_check(@board)
    if king.in_check
      puts "#{player.name} is in check! Oh no!"
      @checkmate = checkmate?(king)
      puts "Checkmate!" if @checkmate
    end
  end


  def look_ahead_for_check(is_white, cord1, cord2)
    board = @board.map(&:clone)
    king = is_white ? @white_king : @black_king
    is_king =  board[cord1[0]][cord1[1]].is_a?(King)
    king.curr_location = [cord2[0], cord2[1]] if is_king
    
    board[cord2[0]][cord2[1]] = board[cord1[0]][cord1[1]]
    board[cord1[0]][cord1[1]] = nil

    king.update_in_check(board)
    king.curr_location = [cord1[0], cord1[1]] if is_king
    if king.in_check
      king.in_check = false
      return true
    end
    false
  end

  

  def piece_row(is_white, row, row_index)
    8.times do |i|
      row[i] = case i
               when 0, 7
                 Rook.new(is_white, [row_index, i])
               when 1, 6
                 Knight.new(is_white, [row_index, i])
               when 3
                 Queen.new(is_white, [row_index, i])
               when 4
                 King.new(is_white, [row_index, i])
               else
                 Bishop.new(is_white, [row_index, i])
               end
    end
  end

  def checkmate?(king)
    # call when already in check. 
    # first check if king can move, else I will brute force it. Considering check is usally resolved by moving the king, 
    # I make that choice. Otherwise you can see if you can block the attacker, or something of the sort. 
    # and continue with more optimization after that, handling situtations by how often they happen. 
    # I believe that becomes a little out of scope for my goals, but it is worth it if you are trying to
    # simulate many chessgames. 


    king.update_possible_moves(@board)
    king.possible_moves.each do |cords|
      return false unless look_ahead_for_check(king.is_white, king.curr_location, cords)
    end

    p 'not here'
    # king can't move, so brute force check every possible move besides the king and see if it does anything.
    my_pieces = king.is_white ? @white_pieces : @black_pieces
    my_pieces.each do |piece|
      next if !piece.is_alive || piece.is_a?(King)
      piece.update_possible_moves(@board)
      piece.possible_moves.each do |cords|
        return false unless look_ahead_for_check(piece.is_white, piece.curr_location, cords)
      end
    end
    #every move has been checked and you can't get out of check, checkmate
    true



  end

  def pawn_row(is_white, row, row_index)
    8.times do |i|
      row[i] = Pawn.new(is_white, [row_index, i])
    end
  end

  def to_s
    result = ''
    divider = '   +---+---+---+---+---+---+---+---+'
    result += divider
    @board.each_with_index do |row, index|
      num = 8 - index
      result += "\n #{num} |"
      row.each do |square|
        token = square.nil? || !square.is_alive ? " " : square.token
        result += " #{token} |"
      end
      result += "\n#{divider}"
    end
    result += "\n     "
    letters = Array("A".."H")
    letters.each {|letter| result += "#{letter}   "}
    #Array("A".."H")
    result
  end
end






#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 6 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 5 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
#         