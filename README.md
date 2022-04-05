# chess

This is my chess! Check it out on replit here: https://replit.com/@losecontrol4/chess#main.rb

## features

Two player chess
Save game
Load game
Undo moves
Castling
En Passant

## how to play

If you are on replit, hit the green run button to start.

else run 'ruby main.rb' with ruby installed to run.

To move, use algorithmic notation. Example, e2e4.

To castle use oo for king side castling, ooo for queen side castling

Type save to save the current game, then type in the name of the file you want (excluding the extension)

Type undo to go back a move (can be done until you are back at the start)

Type help to get information on how to move.

## optimzations

Check:
instead of checking each piece to see if they are attacking the king, I check from the king. See the king class
and moves.rb to see how I do this.

Checkmate:
First I check if the king can do any moves to get out of check (most common way), then I brute force it.
Possibily you can do a few things, checkings other pieces and moves that are also more common, but it becomes more work than it is with in my opinion and will worsen the worse case.

## files

main.rb - driver file, runs the program
lib/pieces - individual classes for each chess piece, and a template class - piece
lib/player.rb - player class, that stores the name and color of the players, and is responsible for getting acceptable input from that player
lib/moves.rb - responsible for most of the game logic, tells each piece how they can move, and tells the king if it is in check
lib/chess.rb - where the magic happens, takes everything together to play a game of chess.
save_files - stores marshal encodings of all saved games

## an interesting problem

Take everything below this more as a blog post for a problem I ran into. One of the hardest type of problems to solve is a performance problem, because it can become a game of where's waldo with your code, searching to find what's causing the problem with little ability to narrow it down. Yet, this type of problem was the most interesting one I ran into while programming this
game of chess.

### what happened?

Each turn I took, the game took longer and longer to load, to the point I was waiting maybe even over three seconds for just a turn! What, chess isn't Crysis, there is no reason for it to start running noticibly slowly!

### what caused it?

The culprit: past states. Luckily, this performance bug was quick to find, because I found it shortly after implementing an undo button. One which used an Array stored of previous states of the chess class, so I can easily go back to a previous one. The issue happened with the way to deep copy objects in ruby-- serializing. Since there is no official way to deep copy an object, the easiest way to make a unique copy is to encode it and then un-encode it. I use marshal to do this in my chess program. What actually happened to the class as I did this turned out to be an interesting math problem.

### math

    What happens when you add a state of a class to an array when the class includes an array of
    pasts states. Well...this with x = turn you are on. [x] = contains everything within state x in addition to itself.
    Nil is a class that has nothing in it's state_array, a number is an instance of the object class.
    The same number refers to the same instance.

    State_array(x) = [1] -> nil
                     [2] -> [1]
                     [3] -> [2], [1]
                     [4] -> [3], [2], [1]
                     [5] -> [4], [3], [2], [1]
                     [6] -> [5], [4], [3], [2], [1]
                     [7] -> [6], [5], [4], [3], [2], [1]
                     [8] -> [7], [6], [5], [4], [3], [2], [1]
                     [x] -> [x - 1] .. [1]

    Therefore state_array(10) contains -> [9], [8], [7], [6], [5], [4], [3], [2], [1]
             x |nums| -> nums refer to all the values held within x
             with [1] = nil
                  [2] = 1 |nil|
                  [3] = 2 |1 |nil||, 1 |nil|
                  [4] = 3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil|
                  [5] = 4 |3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil|
                  [6] = 5 |4 |3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 4 |3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil|
                  [7] = 6 |5 |4 |3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 4 |3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 5 |4 |3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 4 |3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil|
                  [8] = 7 |6 |5 |4 |3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 4 |3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 5 |4 |3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 4 |3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 6 |5 |4 |3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 4 |3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 5 |4 |3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 4 |3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil||, 3 |2 |1 |nil||, 1 |nil||, 2 |1 |nil||, 1 |nil|



    As you could see, this scales extremely quick, making even something as
    low computational power as chess lag. The solution was simply to exclude the s
    erialization of the state array at all, storing it in a temp variable, setting it to nil,
    then compressing, then putting the temp variable into it. But that's not the interesting bit.
    The interesting bit is interpreting this as O(x) where x is which turn you are on and it is
    equal to the number of chess states stored.

    To grasp what is actually going on, let's watch it grow.

    f(1) = 1
    f(2) = 1 + f(2 - 1) = 2
    f(3) = 1 + f(3 - 1) + 1 + f(3 - 2) = 5
    f(4) = 1 + f(4 - 1) + 1 + f(4 - 2) + 1 + f(4 - 3) = 11
    f(5) = 1 + f(4) + 1 + f(3) + 1 + f(2) + 1 + f(1) = 4 + 11 + 5 + 2 + 1 = 23
    f(6) = 1 * (6 - 1) + 23 + 11 + 5 + 2 + 1 = 47

    f(7) = 6 + 47 + 23 + 11 + 5 + 2 + 1 = 95
    f(8) = 7 + 95 + 47 + 23 + 11 + 5 + 2 + 1 = 191
    f(9) = 8 + 191 + 95 + 47 + 23 + 11 + 5 + 2 + 1 = 383
    f(10) = 9 + 383 + 191 + 95 + 47 + 23 + 11 + 5 + 2 + 1 = 767 instances of the chess class saved in ten moves -_-. Only ten moves were intended to be stored.


    From doing this, I deduced that the equation is something like this

    (this proved to be a challenge to type, prevented from using proper notation)

    f(x) = x - 1 + ∑f(i) where i = 1 to x - 1 : f(1) = 1

### time complexity

    After much thinking and experimenting, I reduced the equation to equal f(x) = 2f(x - 1) + 1 : f(2) = 2 : f(1) = 1
    With this, I generated a program to get a larger lookup table in the bug_time_complexity.rb program. I have deduced this particular
    problem is around O(2^n) where n is the turn we are on. After much research and creating a lookup table,
    I can confidently say it takes no longer than n^2 at any given part, so it is a big Oh notation I am happy with.
    I feel like an exact equation is more of a graduate level math problem.

    Conclusion: O(2^N)

    WOW! that grows realllllly fast.
