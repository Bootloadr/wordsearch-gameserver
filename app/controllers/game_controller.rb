class GameController < ApplicationController
  def index
   # @arr = Array.new
    #REDIS.sunionstore(players,cookies.signed[:game_id])
    #while REDIS.spop(players)
    #@arr.push(REDIS.spop(players))
    #while REDIS.spop(players)
    #@arr.push(REDIS.spop(players))
  
  end
  
  def info
    #REDIS.sunionstore(players,cookies.signed[:game_id])
    redirect_to game_index_path
  end
  def back
    redirect_to grid_index_path
  end
end
