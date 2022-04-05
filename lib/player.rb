# Player class, contains infomation like player name, their token, and their current score
# handles getting valid input from the player

class Player
    attr_reader :name, :score
    attr_accessor :is_white
    def initialize(name)
      @name = name
      @score = 0 # unused
      @is_white = nil
    end
  
    def increment_score # unused
      @score += 1
    end
  
    def get_move
      # returns a valid string obtained from the player that is acceptable input
      puts "#{@name}, what's your move?"
      input_valid = false

      until input_valid
        input = gets.chomp
  
        if input.length != 4 && input.length != 5 
          return input.downcase if input.downcase == 'ooo' || input.downcase == 'oo' || input == '000' || input == '00'
          #checks that here for optimzation reasons
          puts "#{@name}, please enter a valid input like a2 b2 or a2b2"
          next # jumps to the top of the while loop
        end

        return input.downcase if input.downcase == 'save' || input.downcase == 'undo' || input.downcase == 'help'
  
        input = input.gsub(/\s+/, "")
        input = input.split("") #turns it to an array to be able to traverse through each character
        valid_char =  Array("A".."H") +  Array("a".."h")
        input_valid = true
        
        input.each_with_index do |char, i|
  
          if i % 2 == 0
           input_valid = false unless valid_char.include?(char)
          else
            input_valid = false if char.to_i < 1 || char.to_i > 8
          end
        end
        puts "please make sure you use numbers 1 through 8, and letters a through h like a3b5" if !input_valid

      end
      input
    end
  
  end
  