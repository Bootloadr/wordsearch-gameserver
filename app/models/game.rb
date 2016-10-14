class Game < ApplicationRecord
 
  def self.start(data, plr_id)
    game_id = REDIS.get("user_#{plr_id}")
    if REDIS.get("status_#{game_id}") == ("Completed").to_s
      return
    end
    #NOT STARTED
    if REDIS.get("status_#{game_id}") == ("Waiting").to_s
      return
    end
    
    #ITS NOT YOUR TURN Check
    if REDIS.get("turn_#{game_id}") != plr_id
       return
    end
    #Pass Logic
    if data['word'].blank?
      REDIS.srem("plrtoplay_#{game_id}",plr_id)
      if REDIS.scard("plrtoplay_#{game_id}").to_i == 0 
        REDIS.set("status_#{game_id}","Completed")
        REDIS.set("turn_#{game_id}", "123")
        turn = ""
        ActionCable.server.broadcast "game_#{game_id}", { msg: "Game Finished" , turn: turn, award: "" , gamestatus: REDIS.get("status_#{game_id}")}
        return
      end
      temp = REDIS.srandmember("plrtoplay_#{game_id}") 
      turn = "Turn: #{REDIS.hget(temp,"name")}"
      REDIS.set("turn_#{game_id}",temp)
      #REDIS.set("passcount_#{game_id}", (REDIS.get("passcount_#{game_id}").to_i + 1).to_s)
      ActionCable.server.broadcast "game_#{game_id}", { msg: "PASS!" , turn: turn, award: "", gamestatus: REDIS.get("status_#{game_id}")}
      return
    end
    #Word Cheking
    #REDIS.set("passcount_#{game_id}", 0)
    REDIS.sunionstore("plrtoplay_#{game_id}",game_id)
    board = REDIS.lrange("grid_#{game_id}", 0, -1 )
    temp = REDIS.srandmember("plrtoplay_#{game_id}")
    while temp == plr_id do
            temp = REDIS.srandmember("plrtoplay_#{game_id}")
    end
    turn = "Turn: #{REDIS.hget(temp,"name")}"
    REDIS.set("turn_#{game_id}",temp)
    award = " Points awarded: 0"
    if  REDIS.sismember("foundwords_#{game_id}", data['word'].upcase)
      msg = "#{REDIS.hget(plr_id,"name")}, FAILED!"
      ActionCable.server.broadcast "game_#{game_id}", { msg: msg , turn: turn, award: award, gamestatus: REDIS.get("status_#{game_id}")}
      return
    end
    if search(data['word'], board) and (REDIS.sismember("wordlist", data['word'].upcase))
        REDIS.sadd("foundwords_#{game_id}", data['word'].upcase)
        REDIS.hset(plr_id, "points", (REDIS.hget(plr_id, "points").to_i + 1).to_s)
        msg = "#{REDIS.hget(plr_id,"name")}, SUCCESS!"
        award = " Points awarded: 1"
        
        #ALL WORD FOUND
        if REDIS.get("wordcounts_#{game_id}").to_i == REDIS.scard("foundwords_#{game_id}").to_i
        REDIS.set("status_#{game_id}","Completed")
        REDIS.set("turn_#{game_id}", "123")
        turn = ""
        ActionCable.server.broadcast "game_#{game_id}", { msg: "Game Finished! No new word left on Grid" , turn: turn, award: award , gamestatus: REDIS.get("status_#{game_id}")}
        return
        end
        
        ActionCable.server.broadcast "game_#{game_id}", { msg: msg , turn: turn, award: award, gamestatus: REDIS.get("status_#{game_id}")}
       return
    end
    msg = "#{REDIS.hget(plr_id,"name")}, FAILED!"
    ActionCable.server.broadcast "game_#{game_id}", { msg: msg , turn: turn, award: award , gamestatus: REDIS.get("status_#{game_id}")}  
  end
  
  private
  
   # verify the words
  def self.search(word, board)
       
       0.upto(14) do |y|
         0.upto(14) do |x|
           [-1, 0, 1].each do |dy|
             [-1, 0, 1].each do |dx|
               next if dx == 0 and dy == 0
               if self.search_for(word.strip.upcase,board, x, y, dx, dy) 
                  return true
               end
             end
           end
         end
       end
        return false
     end

     # search for word in board starting at position (x,y) and moving in
     # direction (dx,dy). returns true if found, false if not found.
     def self.search_for(word,board, x, y, dx, dy)
       return false if x < 0                 or
                       x >= 15 or
                       y < 0                 or
                       y >= 15
       return false if board[15*x + y] != word[0]
       return true if word.length <= 1
       return search_for(word[1,word.length-1],board, x + dx, y + dy, dx, dy)
     end
   
   #total words on grid
   def self.gridset(board,game_id)
       0.upto(14) do |y|
         0.upto(14) do |x|
           [-1, 0, 1].each do |dy|
             [-1, 0, 1].each do |dx|
               next if dx == 0 and dy == 0
                word = ""               
                self.gridset_all(word,game_id,board, x, y, dx, dy) 
               end
             end
           end
         end
    end
     
     def self.gridset_all(word,game_id,board, x, y, dx, dy)
              return  if x < 0                 or
                       x >= 15 or
                       y < 0                 or
                       y >= 15
              word = word + board[15*x+y]
              REDIS.sadd("gridwords_#{game_id}",word)
              gridset_all(word,game_id,board, x + dx, y + dy, dx, dy)
              
     end
     
end