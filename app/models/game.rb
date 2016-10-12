class Game < ApplicationRecord
 
  def self.start(data, plr_id)
    game_id = REDIS.get("user_#{plr_id}")
    if REDIS.get("status_#{game_id}") == ("Completed").to_s
      return
    end
    #ITS NOT YOUR TURN Check
    if REDIS.get("turn_#{game_id}") != plr_id
       #ActionCable.server.broadcast "game_#{game_id}", { msg: "ITS NOT YOUR TURN" , gamestatus: REDIS.get("status_#{game_id}")}
      return
    end
    #Pass Logic
    if data['word'].blank?
      if REDIS.get("passcount_#{game_id}").to_i == (REDIS.scard(game_id) - 1).to_i 
      #REDIS.set("passcount_#{game_id}", (REDIS.get("passcount_#{game_id}").to_i + 1).to_s)
      REDIS.set("status_#{game_id}","Completed")
      turn = "Game Completed!"
      ActionCable.server.broadcast "game_#{game_id}", { msg: "Game Finished" , turn: turn, gamestatus: REDIS.get("status_#{game_id}")}
      return
      end
      temp = REDIS.srandmember(game_id) 
      turn = "Turn: #{REDIS.hget(temp,"name")}"
      REDIS.set("turn_#{game_id}",temp)
      REDIS.set("passcount_#{game_id}", (REDIS.get("passcount_#{game_id}").to_i + 1).to_s)
      ActionCable.server.broadcast "game_#{game_id}", { msg: "PASS!" , turn: turn, gamestatus: REDIS.get("status_#{game_id}")}
      return
    end
  #  if REDIS.get("passcount_#{game_id}").to_i == REDIS.scard(game_id)
   #    REDIS.set("status_#{game_id}","Completed")
    #   ActionCable.server.broadcast "game_#{game_id}", { msg: msg , turn: turn, gamestatus: REDIS.get("status_#{game_id}")}  
     #  return
    #end
    #Word Cheking
    #if REDIS.get("status_#{game_id}") != "Completed" and REDIS.get("status_#{game_id}") != "Waiting"
    temp = REDIS.srandmember(game_id) 
    turn = "Turn: #{REDIS.hget(temp,"name")}"
    REDIS.set("turn_#{game_id}",temp)
    award = "Points awarded: 0"
    if  REDIS.sismember("foundwords_#{game_id}", data['word'].upcase)
      msg = "#{REDIS.hget(plr_id,"name")}, FAILED!"
      ActionCable.server.broadcast "game_#{game_id}", { msg: msg , turn: turn, gamestatus: REDIS.get("status_#{game_id}")}
      return
    end
    if (REDIS.sismember("wordlist", data['word'].upcase))
        REDIS.sadd("foundwords_#{game_id}", data['word'].upcase)
        REDIS.hset(plr_id, "points", (REDIS.hget(plr_id, "points").to_i + 1).to_s)
        msg = "#{REDIS.hget(plr_id,"name")}, SUCCESS!"
        award = "Points awarded: 1"
       ActionCable.server.broadcast "game_#{game_id}", { msg: msg , turn: turn, gamestatus: REDIS.get("status_#{game_id}")}
       return
    end
    msg = "#{REDIS.hget(plr_id,"name")}, FAILED!"
    REDIS.set("passcount_#{game_id}", 0)
    ActionCable.server.broadcast "game_#{game_id}", { msg: msg , turn: turn, gamestatus: REDIS.get("status_#{game_id}")}  
  end
end