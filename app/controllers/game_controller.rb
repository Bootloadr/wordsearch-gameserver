class GameController < ApplicationController
  def index
  
  end
  
  def info
    redirect_to game_index_path
  end
  def back
    redirect_to grid_index_path
  end
end
