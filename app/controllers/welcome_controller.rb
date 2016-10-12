class WelcomeController < ApplicationController
  def join
    @grid = Grid.new
    @grid.add_word("ABHINAV")
  end

  def create
  end
end
