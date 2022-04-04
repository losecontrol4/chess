Dir[File.join(__dir__, 'lib', '*.rb')].each { |file| require file }


def new_game
    puts "You two will play chess to the death!"
    puts 'Please enter who will be white: '
    player1 = gets.chomp
    puts "Welcome #{player1}!"
    puts 'Please enter who will be black'
    player2 = gets.chomp
    puts "Welcome #{player2}!"

    if player1 == player2 # If the players enter the same exact string, then create a way to differ between the two
    puts "well that's confusing..."
    player2 += '2'
    puts "the second player is now #{player2}"
    end
    Chess.new(Player.new(player1), Player.new(player2))
end

def load_game
    files = Dir[File.join(__dir__, 'save_files', '*.txt')]
    puts "These are your options:"
    files.each_with_index do |file, i|
        puts "#{File.basename(file)}(#{i})"
    end
    puts "please input the number corresponding to your choice!"

    input_valid = false
    while !input_valid
        input = gets.chomp
        if input.to_i.to_s != input
            puts "please enter a number"
            next
        end
        input = input.to_i
        if input > files.length - 1 || input < 0
            puts "please enter a valid number 0 to #{files.length - 1}."
            next
        end
        input_valid = true
    end
    Chess.load(files[input])
end





 puts '-----------------------------------------------------'
 puts 'Welcome, would you like to start a new game or load a game?'
 puts 'Start(0) Load(1)'
 input_valid = false
 while !input_valid
    input = gets.chomp
    if input != '0' && input != '1'
        puts "please choose 0 or 1!"
        next
    end
    input_valid = true
 end

 game = input == '0' ? new_game : load_game
 game.play

#player1, player2 = player2, player1 #swaps who is player one and who is player two



#puts "After a tough fight, #{last_winner.name} won, #{player1.score} to #{player2.score}. They are the best, around. Nobody's going to put them down."