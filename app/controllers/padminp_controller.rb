class PadminpController < ApplicationController
  def index  
  end
  def play
    game_id = cookies.signed[:game_id]
    if REDIS.scard(game_id) == 1
      redirect_to padminp_index_path, :flash => {:notice => "No Player has joined the game! Please wait"}
    else
    @grid = Grid.new 
    #Dictionary Creation
    if REDIS.scard("wordlist") 
    # Dictinary already created!
    else
    words = IO.read('/usr/share/dict/words').split("\n")
    words.select!{ |e| e[/[a-zA-Z]+/] == e }
    words.each { |word| REDIS.sadd("wordlist", word.upcase)}
    end
    # Add 10 words to the Grid on Game Start
    arr = REDIS.srandmember("wordlist", 10)
     x = Integer(15)
     y = Integer(3)
     #dir = "right_left"
    arr.each  do  |t| 
      @grid.add_word(t,x,y)
      y += 1
      end
    arr.each { |t| REDIS.sadd("foundwords_#{game_id}",t)}
    
    REDIS.pipelined{ @grid.rows.each{ |elem| REDIS.rpush("grid_#{game_id}",elem) } }
   
    #Counting Total number of words present on the Grid, to complete the game when all words on grid identified
    #Processor will go high in doing this, each words of dictionary are verified for presennce on grid to get word counts on grid
    #Its a time consuming task, so when ADMIN starts game, he has to wait for 1 to 2 mins to load game window to satify all word found!    

    board = REDIS.lrange("grid_#{game_id}", 0, -1 )

    Game.gridset(board, game_id)
    total = REDIS.sinter("wordlist","gridwords_#{game_id}").size
    REDIS.set("wordcounts_#{game_id}", total) 
    REDIS.set("status_#{game_id}","In Play")
    REDIS.sunionstore("plrtoplay_#{game_id}",game_id)
    redirect_to grid_index_path
    end
  end
end
