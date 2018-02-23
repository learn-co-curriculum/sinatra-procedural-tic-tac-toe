require_relative 'config/environment'

class Application < Sinatra::Base

  get '/' do
    @board = {}
    @current_player = "X"
    erb :index
  end

  get "/about" do

    erb :about
  end

  post '/turn' do
    # @original_board = params["original_board"]
    # params.delete("original_board")

    puts params

    @board = Hash[params.keys.map(&:to_i).zip(params.values)]
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


def position_taken?(board, location)
  !(board[location].nil?)
end

# Define your WIN_COMBINATIONS constant
WIN_COMBINATIONS = [
  [0,1,2],
  [3,4,5],
  [6,7,8],
  [0,3,6],
  [1,4,7],
  [2,5,8],
  [0,4,8],
  [6,4,2]
]

# Define won?, full?, draw?, over?, and winner below
def won?(board)
  WIN_COMBINATIONS.detect do |combo|
    board[combo[0]] == board[combo[1]] &&
    board[combo[1]] == board[combo[2]] &&
    position_taken?(board, combo[0]) && board[combo[0]] != ""
  end
end

def full?(board)
  board.all?{|token| token == "X" || token == "O"}
end

def draw?(board)
  full?(board) && !won?(board)
end

def over?(board)
  won?(board) || draw?(board)
end

def winner(board)
  if winning_combo = won?(board)
    board[winning_combo.first]
  end
end

def valid_move?(board, position)
  position = position.to_i
  position = position - 1
  if position.between?(0, 8) && !position_taken?(board, position)
    true
  else
    false
  end
end

def turn_count(board)
  turn_counter = -1
  board_counter = 0
  board.each do |position|
    turn_counter += 1
    if board[turn_counter] == "X" || board[turn_counter] == "O"
      board_counter += 1
    end
  end
  return board_counter
end

def current_player(board)
  if turn_count(board) % 2 == 0
    return "X"
  else
    return "O"
  end
end


