# -*- coding: UTF-8 -*-
require 'test_helper'

require 'ugly_trivia/game'

class GameTest < MiniTest::Unit::TestCase
  # 前処理
  def setup
    @game = UglyTrivia::Game.new
  end

  # 後処理
  def teardown
    @game = nil
  end

  # define_methodで動的に定義したメソッドテスト
  def test_define_methods
    UglyTrivia::Game::CATEGORIES.each do |category|
      random_index_for_create_question(category)
    end
  end

  # initializeテスト
  # インスタンス変数の初期化チェック
  def test_initialize
    tests = {
      "@players" => [],
      "@places" => [0,0,0,0,0,0],
      "@purses" => [0,0,0,0,0,0],
      "@in_penalty_box" => [nil,nil,nil,nil,nil,nil],
      "@current_player" => 0,
      "@is_getting_out_of_penalty_box" => false,
    }

    questions = nil
    ["pop", "science", "sports", "rock"].each do |category|
      questions = []
      50.times.each do |i|
        questions << "#{category.capitalize} Question #{i}"
      end
      tests.store "@#{category}_questions", questions
    end

    tests.each do |k, v|
      assert @game.instance_variable_defined?(k)
      assert_equal v, @game.instance_variable_get(k)
    end
  end

  def test_how_many_players
    assert_equal 0, @game.how_many_players
    @game.instance_variable_set "@players", ["player1"]
    assert_equal 1, @game.how_many_players
    @game.instance_variable_set "@players", ["player1", "player2", "player3"]
    assert_equal 3, @game.how_many_players
  end

  def test_is_playable
    refute @game.is_playable?
    @game.instance_variable_set "@players", ["player1"]
    refute @game.is_playable?
    @game.instance_variable_set "@players", ["player1", "player2"]
    assert @game.is_playable?
    @game.instance_variable_set "@players", ["player1", "player2", "player3"]
    assert @game.is_playable?
  end

  def test_add
    add_players = %w{Namihei Fune Sazae}
    @game.instance_variable_set "@places", Array.new(6, 1)
    @game.instance_variable_set "@purses", Array.new(6, 2)
    @game.instance_variable_set "@in_penalty_box", Array.new(6, nil) 

    assert @game.add(add_players[0])
    players = @game.instance_variable_get("@players")
    assert_equal 1, players.length
    assert_equal add_players[0], players[0]

    assert_equal 1, @game.instance_variable_get("@places")[0]
    assert_equal 0, @game.instance_variable_get("@places")[1]
    assert_equal 1, @game.instance_variable_get("@places")[2]
    assert_equal nil, @game.instance_variable_get("@places")[6]

    assert_equal 2, @game.instance_variable_get("@purses")[0]
    assert_equal 0, @game.instance_variable_get("@purses")[1]
    assert_equal 2, @game.instance_variable_get("@purses")[2]
    assert_equal nil, @game.instance_variable_get("@purses")[6]

    assert_equal nil, @game.instance_variable_get("@in_penalty_box")[0]
    assert_equal false, @game.instance_variable_get("@in_penalty_box")[1]
    assert_equal nil, @game.instance_variable_get("@in_penalty_box")[2]
    assert_equal nil, @game.instance_variable_get("@in_penalty_box")[6]

    assert @game.add(add_players[1])
    assert @game.add(add_players[2])
    players = @game.instance_variable_get("@players")
    assert_equal 3, players.length
    assert_equal add_players[0], players[0]
    assert_equal add_players[1], players[1]
    assert_equal add_players[2], players[2]

    assert_equal 1, @game.instance_variable_get("@places")[0]
    assert_equal 0, @game.instance_variable_get("@places")[1]
    assert_equal 0, @game.instance_variable_get("@places")[2]
    assert_equal 0, @game.instance_variable_get("@places")[3]
    assert_equal 1, @game.instance_variable_get("@places")[4]
    assert_equal 1, @game.instance_variable_get("@places")[5]

    assert_equal 2, @game.instance_variable_get("@purses")[0]
    assert_equal 0, @game.instance_variable_get("@purses")[1]
    assert_equal 0, @game.instance_variable_get("@purses")[2]
    assert_equal 0, @game.instance_variable_get("@purses")[3]
    assert_equal 2, @game.instance_variable_get("@purses")[4]
    assert_equal 2, @game.instance_variable_get("@purses")[5]

    assert_equal nil, @game.instance_variable_get("@in_penalty_box")[0]
    assert_equal false, @game.instance_variable_get("@in_penalty_box")[1]
    assert_equal false, @game.instance_variable_get("@in_penalty_box")[2]
    assert_equal false, @game.instance_variable_get("@in_penalty_box")[3]
    assert_equal nil, @game.instance_variable_get("@in_penalty_box")[4]
    assert_equal nil, @game.instance_variable_get("@in_penalty_box")[5]
  end

  def test_roll
    @game.instance_variable_set("@players", ["Sazae", "Masuo"])
    @game.roll(1)
    assert_equal 0, @game.instance_variable_get("@current_player")
    assert_equal "Sazae", @game.instance_variable_get("@players")[0]
    assert_equal 1, @game.instance_variable_get("@places")[0]
    assert_equal "Science", @game.send("current_category")

    @game.instance_variable_set("@in_penalty_box", [true, nil, nil, nil, nil, nil])
    @game.roll(2)
    assert_equal 0, @game.instance_variable_get("@current_player")
    assert_equal "Sazae", @game.instance_variable_get("@players")[0]
    assert_equal 1, @game.instance_variable_get("@places")[0]
    refute @game.instance_variable_get("@is_getting_out_of_penalty_box")

    @game.roll(3)
    assert_equal 0, @game.instance_variable_get("@current_player")
    assert_equal "Sazae", @game.instance_variable_get("@players")[0]
    assert_equal 4, @game.instance_variable_get("@places")[0]
    assert_equal "Pop", @game.send("current_category")
    assert @game.instance_variable_get("@is_getting_out_of_penalty_box")
  end

  def test_was_correctly_answered
    @game.instance_variable_set("@players", ["Sazae", "Masuo"])
    assert_equal 0, @game.instance_variable_get("@current_player")
    assert_equal "Sazae", @game.instance_variable_get("@players")[0]
    assert_equal nil, @game.instance_variable_get("@in_penalty_box")[0]
    assert_equal 0, @game.instance_variable_get("@purses")[0]

    assert_equal true, @game.was_correctly_answered
    assert_equal 1, @game.instance_variable_get("@purses")[0]
    assert_equal 1, @game.instance_variable_get("@current_player")

    @game.instance_variable_set("@in_penalty_box", [true,true,nil,nil,nil,nil])
    assert_equal true, @game.was_correctly_answered
    assert_equal 1, @game.instance_variable_get("@purses")[0]
    assert_equal 0, @game.instance_variable_get("@purses")[1]
    assert_equal 0, @game.instance_variable_get("@current_player")

    @game.instance_variable_set("@is_getting_out_of_penalty_box", true)
    @game.instance_variable_set("@purses", [5,0,0,0,0,0])
    assert_equal false, @game.was_correctly_answered
    assert_equal 6, @game.instance_variable_get("@purses")[0]
    assert_equal 1, @game.instance_variable_get("@current_player")
  end

  def test_wrong_answer
    @game.instance_variable_set("@players", ["Sazae", "Masuo"])
    assert_equal 0, @game.instance_variable_get("@current_player")
    assert_equal "Sazae", @game.instance_variable_get("@players")[0]
    assert_equal nil, @game.instance_variable_get("@in_penalty_box")[0]

    assert @game.wrong_answer
    assert_equal 1, @game.instance_variable_get("@current_player")
    assert_equal "Masuo", @game.instance_variable_get("@players")[1]
    assert_equal true, @game.instance_variable_get("@in_penalty_box")[0]
  end

  def test_ask_question
    ary = []
    12.times.each { |i| ary << i }
    @game.instance_variable_set("@places", ary)

    3.times.each do |i|
      @game.instance_variable_set("@current_player", 4 * i)
      assert_equal 'Pop', @game.send("current_category")
      assert_output("Pop Question #{i}\n"){ @game.send("ask_question") }
      @game.instance_variable_set("@current_player", 4 * i + 1)
      assert_equal 'Science', @game.send("current_category")
      assert_output("Science Question #{i}\n"){ @game.send("ask_question") }
      @game.instance_variable_set("@current_player", 4 * i + 2)
      assert_equal 'Sports', @game.send("current_category")
      assert_output("Sports Question #{i}\n"){ @game.send("ask_question") }
      @game.instance_variable_set("@current_player", 4 * i + 3)
      assert_equal 'Rock', @game.send("current_category")
      assert_output("Rock Question #{i}\n"){ @game.send("ask_question") }
    end
  end

  def test_did_player_win
    @game.instance_variable_set("@purses", [0,1])
    @game.instance_variable_set("@current_player", 1)
    assert_equal true, @game.send("did_player_win")
    @game.instance_variable_set("@purses", [0,5])
    assert_equal true, @game.send("did_player_win")
    @game.instance_variable_set("@purses", [0,6])
    assert_equal false, @game.send("did_player_win")
    @game.instance_variable_set("@purses", [0,7])
    assert_equal true, @game.send("did_player_win")
  end


  private

  # create_xxx_questionメソッドテスト
  def random_index_for_create_question(category)
    # respond_to?
    assert_respond_to(@game, "create_#{category}_question", "create_#{category}_questionメソッドが定義されていない！")
    # 0-1000からランダムに抽出した値と一致するか5回試す
    5.times.each do |i|
      index = rand(1000)
      assert_equal "#{category.capitalize} Question #{index}", @game.send("create_#{category}_question", index)
    end
  end
end
