Dir[File.join(__dir__, 'lib', '*.rb')].each { |file| require file }


# test = Chess.new(Player.new("Adam"), Player.new("Courtney"))

# puts test
# test.make_move(false, Chess.algnot_to_cord('e7'), Chess.algnot_to_cord('e6'))
# test.make_move(false, Chess.algnot_to_cord('d8'), Chess.algnot_to_cord('h4'))
# test.make_move(false, Chess.algnot_to_cord('h4'), Chess.algnot_to_cord('f2'))
# p test.make_move(true, Chess.algnot_to_cord('a2'), Chess.algnot_to_cord('a3'))
# test.white_king.update_in_check(test.board)
# p test.white_king.in_check
# puts test


def test_checkmate
    p1 = Player.new("Adam")
    p2 = Player.new("Courtney")
    test = Chess.new(p1, p2)
    test.make_move(true, Chess.algnot_to_cord('e2'), Chess.algnot_to_cord('e3'))
    test.make_move(true, Chess.algnot_to_cord('f1'), Chess.algnot_to_cord('c4'))
    test.make_move(true, Chess.algnot_to_cord('d1'), Chess.algnot_to_cord('h5'))
    test.make_move(true, Chess.algnot_to_cord('h5'), Chess.algnot_to_cord('f7'))
    test.update_checkmate(p2)
    p test.checkmate
end

test_checkmate

# p test.make_move(true, [6, 0], [5, 0])
# p test.make_move(true, [6, 0], [5, 0])




# test = Bishop.new(true, [4, 4])
# board = Array.new(8) {Array.new(8, nil)}
# board[2][6] = Bishop.new(false, nil)

# test.update_possible_moves(board)
# p test.possible_moves


# test = Rook.new(true, [4, 4])
# board = Array.new(8) {Array.new(8, nil)}
# board[4][6] = Rook.new(true, nil)
# board[4][1] = Rook.new(false, nil)
# p "here"
# test.update_possible_moves(board)