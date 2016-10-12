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
    #@grid.save
    REDIS.pipelined{ @grid.rows.each{ |elem| REDIS.rpush("grid_#{game_id}",elem) } }
    #REDIS.rpush "grid_#{game_id}" @grid.rows
    #elements = REDIS.lrange("demo", 0, -1 )
    #render text: REDIS.smembers("wordlist_#{:game_id}")
    REDIS.set("turn_#{game_id}", cookies.signed[:player_id])
    REDIS.set("status_#{game_id}","In Play")
    redirect_to grid_index_path
    end
  end
end
