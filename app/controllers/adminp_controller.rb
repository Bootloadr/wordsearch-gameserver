class AdminpController < ApplicationController
  def index
    
  end
  def create
    game_id = gen_game_id
    player_id = gen_player_id
    nick_name = params[:adminp][:nick]
    if params[:adminp][:nick].blank?
      nick_name = gen_nick
    end
    cookies.signed[:player_id] = player_id
    cookies.signed[:game_id] = game_id
    REDIS.sadd(game_id,player_id)
    REDIS.hmset player_id,"name",nick_name,"points", 0, "admin", true
    REDIS.set("status_#{game_id}","Waiting")
    REDIS.set("turn_#{game_id}", player_id)
    redirect_to padminp_index_path , :flash => {:notice => "Hi #{nick_name} Your GameID:  #{game_id}  and  PlayerID:  #{player_id}"}
 end
  
  private
  def gen_nick
    #possible = ('A'..'Z').to_a
    name = [*('A'..'Z')].sample(4).join #(5).map { |n| possible.sample }.join
    name
  end
  def gen_game_id
    SecureRandom.urlsafe_base64
  end
  
  def gen_player_id
    SecureRandom.urlsafe_base64
  end  
end
