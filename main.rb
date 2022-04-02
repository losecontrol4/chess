Dir[File.join(__dir__, 'lib', '*.rb')].each { |file| require file }

SCORE_TO_WIN = 5

# get player names and give an introduction

# puts '-----------------------------------------------------'
# puts "Welcome, you two will play chess to the death!"
# puts 'Please enter who will be white: '
# player1 = gets.chomp
# puts "Welcome #{player1}!"
# puts 'Please enter who will be black'
# player2 = gets.chomp
# puts "Welcome #{player2}!"

# if player1 == player2 # If the players enter the same exact string, then create a way to differ between the two
#   puts "well that's confusing..."
#   player2 += '2'
#   puts "the second player is now #{player2}"
# end

# create player object
player1 = Player.new("Adam")
player2 = Player.new("Courtney")


#make an option to make it random who goes first
#player1, player2 = player2, player1 if rand(0..1).zero? # randomly swaps who goes first




game = Chess.new(player1, player2) #player1 and 2 swap after each game
game.play

#player1, player2 = player2, player1 #swaps who is player one and who is player two



#puts "After a tough fight, #{last_winner.name} won, #{player1.score} to #{player2.score}. They are the best, around. Nobody's going to put them down."