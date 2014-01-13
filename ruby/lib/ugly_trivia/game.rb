# -*- coding: UTF-8 -*-
module UglyTrivia
  class Game
    CATEGORIES = %w{ pop science sports rock }

    # create {pop,science,sports,rock} question まとめてメソッド定義
    CATEGORIES.each do |category|
      define_method "create_#{category}_question" do |index|
        "#{category.capitalize} Question #{index}"
      end
    end

    def initialize
      @players = []
      @places = Array.new(6, 0)
      @purses = Array.new(6, 0)
      @in_penalty_box = Array.new(6, nil)

      @current_player = 0
      @is_getting_out_of_penalty_box = false

      # カテゴリー毎の質問リストを初期化
      CATEGORIES.each do |category|
        instance_variable_set("@#{category}_questions", [])
      end
      50.times do |i|
        CATEGORIES.each do |category|
          eval("@#{category}_questions").push send("create_#{category}_question", i)
        end
      end
    end

    def is_playable?
      how_many_players >= 2
    end

    def add(player_name)
      @players.push player_name
      @places[how_many_players] = 0
      @purses[how_many_players] = 0
      @in_penalty_box[how_many_players] = false

      puts "#{player_name} was added"
      puts "They are player number #{@players.length}"

      true
    end

    def how_many_players
      @players.length
    end

    def roll(roll)
      puts "#{@players[@current_player]} is the current player"
      puts "They have rolled a #{roll}"

      if @in_penalty_box[@current_player]
        if !can_comeback?(roll)
          puts "#{@players[@current_player]} is not getting out of the penalty box"
          @is_getting_out_of_penalty_box = false
          return
        end

        @is_getting_out_of_penalty_box = true
        puts "#{@players[@current_player]} is getting out of the penalty box"
      end

      move_place(roll)
      puts "#{@players[@current_player]}'s new location is #{@places[@current_player]}"

      puts "The category is #{current_category}"
      ask_question
    end

    def was_correctly_answered
      is_continue = true

      if @in_penalty_box[@current_player]
        if @is_getting_out_of_penalty_box
          puts 'Answer was correct!!!!'
          @purses[@current_player] += 1
          puts "#{@players[@current_player]} now has #{@purses[@current_player]} Gold Coins."

          is_continue = did_player_win
        end

      else
        puts "Answer was corrent!!!!"
        @purses[@current_player] += 1
        puts "#{@players[@current_player]} now has #{@purses[@current_player]} Gold Coins."

        is_continue = did_player_win
      end

      next_player
      return is_continue
    end

    def wrong_answer
  		puts 'Question was incorrectly answered'
  		puts "#{@players[@current_player]} was sent to the penalty box"
  		@in_penalty_box[@current_player] = true

      @current_player += 1
      @current_player = 0 if @current_player == @players.length
  		return true
    end


  private

    def can_comeback?(roll)
      !(roll % 2 == 0)
    end

    def move_place(roll)
      @places[@current_player] = @places[@current_player] + roll
      @places[@current_player] = @places[@current_player] - 12 if @places[@current_player] > 11
    end

    def next_player
      @current_player += 1
      @current_player = 0 if @current_player == @players.length
    end

    def ask_question
      puts @pop_questions.shift if current_category == 'Pop'
      puts @science_questions.shift if current_category == 'Science'
      puts @sports_questions.shift if current_category == 'Sports'
      puts @rock_questions.shift if current_category == 'Rock'
    end

    def current_category
      val = @places[@current_player] % CATEGORIES.length
      return CATEGORIES[val].capitalize
    end

    def did_player_win
      !(@purses[@current_player] == 6)
    end
  end
end
