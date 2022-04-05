require 'set'
require_relative '../moves'

#This class is only to be used as a template parent class, it would not function properly on it's own.
#It sets instance variables and functions to be used by all pieces.
class Piece
  include Moves
  attr_reader :is_white
  attr_accessor :is_alive, :curr_location, :possible_moves
  
  def initialize(is_white, curr_location)
    @is_white = is_white
    @curr_location = curr_location
    @is_alive = true
    @possible_moves = Set.new
  end

  def kill
    @is_alive = false
    @curr_location = nil
  end

  def move(cords)
    @curr_location = cords
  end
  def update_possible_moves(board)
    nil #place holder to be able to call this function in piece. It will be overwrittem in every child class.
  end

  def can_move(board, cords)
    #doesn't check for the move putting your king in check. That has to be done at a higher level
    update_possible_moves(board)
    return !@possible_moves.include?(cords)
  end
end
