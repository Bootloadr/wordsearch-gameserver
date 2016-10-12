class NewpController < ApplicationController
  def index
    
  end
  def join
    if REDIS.scard(params[:newp][:gameId]) == 2
      redirect_to newp_index_path, :flash => {:notice => "Game is Full! You Can't Join"}
    end
    if REDIS.scard(params[:newp][:gameId]) != 0
    #render text: "#{params[:newp][:gameId]}"
    player_id = gen_player_id
    nick_name = params[:newp][:nick]
    if params[:newp][:nick].blank?
      nick_name = gen_nick
    end
    cookies.signed[:player_id] = player_id
    cookies.signed[:game_id] = params[:newp][:gameId]
    REDIS.sadd(params[:newp][:gameId],player_id)
    REDIS.hmset player_id,"name",nick_name,"points", 0, "admin", false
    redirect_to pnewp_index_path, :flash => {:notice => "Hi #{nick_name}, Your PlayerId is #{player_id} "}
   else
    #render text: "WRONG GAME_ID"
    redirect_to newp_index_path, :flash => {:notice => "Wrong GameId, Please try again!"}
   end 
  end
  
    private
  
  def gen_nick
    #possible = ('A'..'Z').to_a
    name = [*('A'..'Z')].sample(4).join #(5).map { |n| possible.sample }.join
    name
  end
  
  def gen_player_id
    SecureRandom.urlsafe_base64
  end  
end
