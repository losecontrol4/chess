Dir[File.join(__dir__, 'pieces', '*.rb')].each { |file| require file }

# where all the magic happens, ties everything together with a chess class that handles playing a game of chess
class Chess
  attr_accessor :board, :white_pieces, :black_pieces, :white_king, :black_king, :player1, :player2, :player1_turn,
                :checkmate, :passant_pawn

  # unfortunately I had to use accessor for so many variables becauese I needed to access them all on another chess object inside this class
  # I can definitely turn many of these into readers

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
    @player1_turn = true
    @passant_pawn = nil
    @past_states = [] # Could be implemented as a stack
  end

  def play
    introduction
    move_done = true
    until @checkmate

      @past_states.push(new_state) if move_done
      

      if @player1_turn
        turn_taker = @player1
        other_player = @player2
      else
        turn_taker = @player2
        other_player = @player1
      end

      puts self if move_done

      result = take_turn(turn_taker)
      move_done = false

      if result == 'undo'
        if @past_states.length < 2
          puts 'There are no moves to undo'
        else
          move_done = true
          update(@past_states.pop(2)[0])
        end
        next
      end
      if result == 'save'
        save
        next
      end
      if result == 'help'
        introduction
        next
      end
      update_checkmate(other_player)

      @player1_turn = !@player1_turn
      move_done = true
    end
    puts self
    winner = !@player1_turn ? @player1 : @player2
    loser = @player1_turn ? @player1 : @player2
    puts "After a long hard fight, the dust clears...#{loser.name} was bested by #{winner.name}.\nTheir intense battle will go down in history most certainly, but one questions remains...will #{loser.name} seek revenge?"
  end

  def introduction 
    puts "Welcome to chess! Enter your move in algorithmic notation Ex: 'e3e4' or 'e3 e4'. Type in 'undo' to go back a move. Type in save, to save your current game (doesn't end the game)"
    puts "To castle, type in 00, OO, or oo for king side castling, 000, OO, or oo for queen side castling."
  end

  def self.algnot_to_cord(algnot)
    # takes a value in algebraic notation, returns coordinates
    [9 - algnot[1].to_i - 1, (algnot[0].downcase.ord - 97)]
  end

  def self.cord_to_algnot(cord)
    # takes coordinates and returns it in algebraic notation
    (cord[1] + 97).chr + (7 - cord[0] + 1).to_s
  end

  def self.load(path)
    # give a full existing path, returns a chess object
    Marshal.load(File.read(path))
  end


  # everything behind this is functions the class uses
  private

  def update(chess)
    #For use to change to a previous state with undo
    @board = chess.board
    @white_pieces = chess.white_pieces
    @black_pieces = chess.black_pieces
    @white_king = chess.white_king
    @black_king = chess.black_king
    @player1 = chess.player1
    @player2 = chess.player2
    @checkmate = chess.checkmate
    @passant_pawn = chess.passant_pawn
    @player1_turn = chess.player1_turn
  end

  def new_state
    temp = @past_states
    @past_states = nil
    result = Marshal.load(Marshal.dump(self)) # apparently the built in ruby way to deep copy an object. It's a little slow, but negligible for the purposes used here.
    @past_states = temp # optimzation to avoid storing each previous state in each state, making the game scale in an insane way, read about this bug in my readme
    result
  end

  def save
    puts "what would you like your save file to be called? (Don't use the extension. You can overwrite existing files)"
    input = gets.chomp
    dir_name = 'save_files/'
    File.open("#{dir_name}#{input}.txt", 'w') { |f| f.write Marshal.dump(self) }
  end

  def take_turn(player)
    outcome = -1
    while outcome != 0
      move = player.get_move
      return move if %w[save undo help].include?(move)

      outcome = if move.length > 3
                  make_move(player.is_white, Chess.algnot_to_cord(move[0..1]),
                            Chess.algnot_to_cord(move[2..3]))
                else
                  castling(player.is_white, move.length)
                end
      case outcome
      when 1
        puts 'A cordinate you entered is out of bounds'
      when 2
        puts 'You need to select your own piece.'
      when 3
        location = Chess.algnot_to_cord(move[0..1])
        piece_type = @board[location[0]][location[1]].class
        puts "That is not a valid move for the #{piece_type} you selected."
      when 4
        puts 'You cannot make a move that leaves git comyou in check.'
      when 5 # castling checks
        puts 'You cannot castle while you are in check.'
      when 6
        puts 'You cannot castle if either your king or the rook chosen has moved.'
      when 7
        puts 'You can only castle if the board between the king and the rook is empty.'
      end
      puts "type 'help' for help" if outcome != 0

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

  def castling(is_white, side)
    # returns 0 if move went well
    # returns 4 if it puts yourself in check
    # returns 5 if you are already in check
    # returns 6 if king or rook selected already moved
    # returns 7 if there is a piece in the way

    row = is_white ? 7 : 0
    col1 = 4
    col2 = side == 2 ? 7 : 0
    king = @board[row][col1]
    rook = @board[row][col2]
    return 6 if !king.is_a?(King) || !rook.is_a?(Rook) || king.moved || rook.moved

    king.update_in_check(@board)
    return 5 if king.in_check

    in_between = side == 2 ? Array(col1 + 1..col2 - 1) : Array(col2 + 1..col1 - 1)
    in_between.each { |col| return 7 unless @board[row][col].nil? }
    cord1 = [row, col1]
    factor_king = side == 2 ? 2 : -2
    cord2 = [row, col1 + factor_king]
    #don't need to move rook because it cannot effect check
    return 4 if look_ahead_for_check(is_white, cord1, cord2)

    # everything is clear, now actually do the move

    king.move([row, col1 + factor_king])
    factor_rook = side == 2 ? -2 : 3
    rook.move([row, col2 + factor_rook])
      
    @board[row][col1 + factor_king] = king
    @board[row][col2 + factor_rook] = rook
    
    @board[row][col1] = nil
    @board[row][col2] = nil

    return 0
    # since you can only castle while not already in check, I only need to check the king movements for check, not the rook because the rook cannot effect check (thankfully because the lookahead function wasn't made for two pieces movin)
  end

  def make_move(is_white, cord1, cord2)
    # returns 0 if move went well
    # returns 1 if either cordinate is out of bounds
    # returns 2 if first cord given doesn't have a piece, or is the enemy's piece
    # returns 3 if the second cord is not a valid move for that piece.
    # returns 4 if the move would put yourself in check
    (cord1 + cord2).each { |val| return 1 if val < 0 || val > 7 }
    piece = @board[cord1[0]][cord1[1]]
    return 2 if piece.nil? || piece.is_white != is_white

    piece.update_possible_moves(@board)

    return 3 unless piece.possible_moves.include?(cord2)
    # need to check if the move puts yourself in check
    return 4 if look_ahead_for_check(is_white, cord1, cord2)

    @board[cord2[0]][cord2[1]].kill unless @board[cord2[0]][cord2[1]].nil? #removes curr_location and makes is_alive false, doesn't effect the board

    # handle en passant ------------------------------

    if piece.is_a?(Pawn) && @board[cord2[0]][cord2[1]].nil? && cord2[1] != piece.curr_location[1]
      factor = is_white ? 1 : -1
      @board[cord2[0] + factor][cord2[1]].kill
      @board[cord2[0] + factor][cord2[1]] = nil
    end
    
    @passant_pawn.passant = 0 unless @passant_pawn.nil?
 
    give_en_passant(piece, cord2) if piece.is_a?(Pawn)
    
    # -------------------------------------------------

  
    piece.move(cord2)
    piece = pawn_upgrade(piece, cord2) if piece.is_a?(Pawn) && (piece.is_white ? 0 : 7) == cord2[0]
    @board[cord2[0]][cord2[1]] = piece
    @board[cord1[0]][cord1[1]] = nil
    return 0
  end

  def give_en_passant(pawn, cord)
    return unless (cord[0] - pawn.curr_location[0]).abs == 2
    [1, -1].each do |factor| 
      col = factor + cord[1]
      next if col < 0 || col > 7
      other_piece = @board[cord[0]][col]
      next if other_piece.nil? || !other_piece.is_a?(Pawn)
      other_piece.passant = factor * -1
      @passant_pawn = other_piece
    end
  end

  def pawn_upgrade(piece, cord2)
    piece.is_alive = false
    piece.curr_location = nil
    result = -1
    player = piece.is_white ? @player1 : @player2
    puts "#{player.name}, please choose a piece to upgrade your pawn to."
    puts 'Queen (1) Knight (2) Rook (3) Bishop (4)'
    while result < 1 || result > 4
      puts 'choose a piece (1 through 4)'
      input = gets.chomp
      if input.to_i.to_s != input
        puts 'please choose a number between 1 and 4'
        next
      end
      result = input.to_i
    end
    case result
    when 1
      new_piece = Queen.new(piece.is_white, cord2)
    when 2
      new_piece = Knight.new(piece.is_white, cord2)
    when 3
      new_piece = Rook.new(piece.is_white, cord2)
    when 4
      new_piece = Bishop.new(piece.is_white, cord2)
    end
  end

  def update_checkmate(player)
    king = player.is_white ? @white_king : @black_king
    king.update_in_check(@board)
    if king.in_check
      puts "#{player.name} is in check! Oh no!"
      @checkmate = checkmate?(king)
      puts 'Checkmate!' if @checkmate
    end
  end

  def look_ahead_for_check(is_white, cord1, cord2)
    board = @board.map(&:clone)
    king = is_white ? @white_king : @black_king
    is_king = board[cord1[0]][cord1[1]].is_a?(King)
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

    # king can't move, so brute force check every possible move besides the king and see if it does anything.
    my_pieces = king.is_white ? @white_pieces : @black_pieces
    my_pieces.each do |piece|
      next if !piece.is_alive || piece.is_a?(King)

      piece.update_possible_moves(@board)
      piece.possible_moves.each do |cords|
        return false unless look_ahead_for_check(piece.is_white, piece.curr_location, cords)
      end
    end
    # every move has been checked and you can't get out of check, checkmate
    true
  end

  def pawn_row(is_white, row, row_index)
    #For use with creating a new board
    8.times do |i|
      row[i] = Pawn.new(is_white, [row_index, i])
    end
  end

  def piece_row(is_white, row, row_index)
    #For use with creating a new board
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

  def to_s
    #For printing the board
    result = ''
    divider = '   +---+---+---+---+---+---+---+---+'
    result += divider
    @board.each_with_index do |row, index|
      num = 8 - index
      result += "\n #{num} |"
      row.each do |square|
        token = square.nil? || !square.is_alive ? ' ' : square.token
        result += " #{token} |"
      end
      result += "\n#{divider}"
    end
    result += "\n     "
    letters = Array('A'..'H')
    letters.each { |letter| result += "#{letter}   " }
    # Array("A".."H")
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
#     A   B   C   D   E   F   G  H
