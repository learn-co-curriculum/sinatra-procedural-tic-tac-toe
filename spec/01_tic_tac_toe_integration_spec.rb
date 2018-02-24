require 'pry'
require 'spec_helper'

describe './app.rb - Tic Tac Toe Sinatra' do
  describe 'GET / - New Game' do
    context 'Request Basics' do
      it 'responds with a 200 status code' do
        get '/'
        expect(last_response).to be_ok
      end
    end

    context 'HTML for GET / - A Game Board' do
      it 'shows a welcome message' do
        visit '/'

        expect(page).to have_text("Welcome to Tic Tac Toe!")
      end

      it 'has a form configured to submit to POST /' do
        visit '/'

        expect(page).to have_selector("form")
        expect(page).to have_selector("form[action='/turn']")
        expect(page).to have_selector("form[method='POST']")
      end

      it 'has a 3x3 table to create the Tic Tac Toe board grid' do
        visit '/'

        expect(page).to have_selector("table")

        # 1st Row with 3 TD cells
        expect(page).to have_selector("table tr:nth-child(1) td:nth-child(1)")
        expect(page).to have_selector("table tr:nth-child(1) td:nth-child(2)")
        expect(page).to have_selector("table tr:nth-child(1) td:nth-child(3)")

        # 2nd Row with 3 TD cells
        expect(page).to have_selector("table tr:nth-child(2) td:nth-child(1)")
        expect(page).to have_selector("table tr:nth-child(2) td:nth-child(2)")
        expect(page).to have_selector("table tr:nth-child(2) td:nth-child(3)")

        # 3rd Row with 3 TD cells
        expect(page).to have_selector("table tr:nth-child(3) td:nth-child(1)")
        expect(page).to have_selector("table tr:nth-child(3) td:nth-child(2)")
        expect(page).to have_selector("table tr:nth-child(3) td:nth-child(3)")
      end

      it 'each table cell contains an input for the correct index in the board' do
        visit '/'

        expect(page).to have_field("0")
        expect(page).to have_field("1")
        expect(page).to have_field("2")
        expect(page).to have_field("3")
        expect(page).to have_field("4")
        expect(page).to have_field("5")
        expect(page).to have_field("6")
        expect(page).to have_field("7")
        expect(page).to have_field("8")
      end

      it 'has a submit button' do
        visit '/'

        expect(page).to have_selector("input[type=submit]")
      end

      it 'submitting the form works' do
        visit '/'

        click_button "Submit Turn"

        expect(page.status_code).to eq(200)
      end
    end
  end

  describe 'POST / - Submitting a Move' do
    context 'Updating the game based on form input' do
      it 'calls board_from_params with params' do
        expect_any_instance_of(Application).to receive(:board_from_params).with({"0" => "", "1" => "X"})

        post '/turn', {"0" => "", "1" => "X"}
      end

      it 'sends `params` to the `#turns` method on the TicTacToe instance' do
        game = TicTacToe.new
        expect(TicTacToe).to receive(:new).twice.and_return(game)

        visit '/'
        fill_in "4", :with => "X"
        click_button "submit"

        expect(game.board).to eq([" ", " ", " ", " ", "X", " ", " ", " ", " "])
        expect(game.turn_count).to eq(1)
        expect(game.current_player).to eq("O")
      end
    end

    context 'Updating the game form in index.erb' do
      it 'sets the values of the form inputs in the board based on the previous moves' do
        visit '/'
        fill_in "4", :with => "X"
        click_button "submit"

        expect(page).to have_field("4", :with => "X")

        visit '/'
        fill_in "4", :with => "X"
        click_button "submit"

        fill_in "0", :with => "O"
        click_button "submit"

        expect(page).to have_field("4", :with => "X")
        expect(page).to have_field("0", :with => "O")
      end

      it 'sets the readonly attribute to inputs that have been previously filled in' do
        visit '/'
        fill_in "4", :with => "X"
        click_button "submit"

        expect(page).to have_field("0", :readonly => false)
        expect(page).to have_field("4", :with => "X", :readonly => true)

        visit '/'
        fill_in "4", :with => "X"
        click_button "submit"

        fill_in "0", :with => "O"
        click_button "submit"

        expect(page).to have_field("4", :with => "X", :readonly => true)
        expect(page).to have_field("0", :with => "O", :readonly => true)
        expect(page).to have_field("8", :readonly => false)
      end
    end

    context 'Winning the game' do
      it 'checks to see if the game is won after every move' do
        game = TicTacToe.new
        allow(TicTacToe).to receive(:new).and_return(game)

        expect(game).to receive(:won?).at_least(:once)

        visit '/'
        fill_in "4", :with => "X"
        click_button "submit"
      end

      it "plays the game and shows the winner page, congratulating X" do
        visit '/'

        fill_in('0', :with => 'X')
        click_button 'submit'

        fill_in('1', :with => 'O')
        click_button 'submit'

        fill_in('4', :with => 'X')
        click_button 'submit'

        fill_in('5', :with => 'O')
        click_button 'submit'

        fill_in('8', :with => 'X')
        click_button 'submit'

        expect(page).to have_text("Congratulations X")
      end

      it "plays the game and shows the winner page, congratulating O" do
        visit '/'

        fill_in('0', :with => 'O')
        click_button 'Submit Move'

        fill_in('1', :with => 'X')
        click_button 'Submit Move'

        fill_in('4', :with => 'O')
        click_button 'Submit Move'

        fill_in('5', :with => 'X')
        click_button 'Submit Move'

        fill_in('8', :with => 'O')
        click_button 'Submit Move'

        expect(page.body).to include("Congratulations O")
      end
    end

    context 'A draw game' do
      it 'checks to see if the game is a draw after every move' do
        game = TicTacToe.new
        allow(TicTacToe).to receive(:new).and_return(game)

        expect(game).to receive(:draw?)

        visit '/'
        fill_in "4", :with => "X"
        click_button "submit"
      end

      it "plays the game and shows the draw page if there is a tie" do
        visit '/'

        fill_in('0', :with => 'X')
        click_button 'submit'

        fill_in('1', :with => 'O')
        click_button 'submit'

        fill_in('2', :with => 'X')
        click_button 'submit'

        fill_in('3', :with => 'O')
        click_button 'submit'

        fill_in('4', :with => 'O')
        click_button 'submit'

        fill_in('5', :with => 'X')
        click_button 'submit'

        fill_in('6', :with => 'X')
        click_button 'submit'

        fill_in('7', :with => 'X')
        click_button 'submit'

        fill_in('8', :with => 'O')
        click_button 'submit'

        expect(page.body).to include("Cats Game!")
      end
    end
  end
end
