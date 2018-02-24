require_relative 'config/environment'

class Application < Sinatra::Base

  get '/' do
    @board = {}
    @current_player = "X"
    erb :index
  end

  post '/turn' do
    @board = board_from_params(params)
    @current_player = current_player(@board)
    if won?(@board)
      @winner = winner(@board)
      erb :winner
    elsif draw?(@board)
      erb :draw
    else
      erb :index
    end
  end
end

