defmodule Phoenanza.GamesTest do
  use Phoenanza.DataCase
  require Logger

  alias Phoenanza.Games
  alias Phoenanza.Games.Game
  
  describe "games" do
    @test_game_name "test game"

    setup do
      Games.clear_cache()
      :ok
    end

    test "new_game/1 creates a new game" do
      {:ok, game} = Games.new_game(@test_game_name)
      assert %Game{} = game
      assert game.id == @test_game_name
      assert Games.list_games() == [@test_game_name]
    end

    test "new_game/1 returns existing game if there is one" do
      {:ok, game} = Games.new_game(@test_game_name)
      assert Games.list_games() == [@test_game_name]    
      assert {:ok, ^game} = Games.new_game(@test_game_name)
      assert Games.list_games() == [@test_game_name]    
    end

    test "join_game/3 lets a player join the game" do
      user = Phoenanza.PlayersTest.user_fixture()
      {:ok, _game} = Games.new_game(@test_game_name)
      assert {:ok, pid} = Games.join_game(@test_game_name, user.id, &dummy_callback/3)
      assert is_pid(pid)
    end
    
    test "join_game/3 only lets two players to join" do
      user = Phoenanza.PlayersTest.user_fixture()
      otherUser = Phoenanza.PlayersTest.user_fixture(%{name: "someone else"})
      {:ok, _game} = Games.new_game(@test_game_name)
      assert {:ok, pid} = Games.join_game(@test_game_name, user.id, &dummy_callback/3)
      assert is_pid(pid)
      assert {:ok, pid2} = Games.join_game(@test_game_name, otherUser.id, &dummy_callback/3)
      assert is_pid(pid2)
      assert pid != pid2
      assert {:error, :game_full} = Games.join_game(@test_game_name, user.id, &dummy_callback/3)
    end

    test "find_game/1 finds the game by name" do
      {:ok, game} = Games.new_game(@test_game_name)
      assert Games.find_game(@test_game_name) == game
    end

    test "stop_game/1 stops a game" do
      {:ok, _game} = Games.new_game(@test_game_name)
      assert Games.list_games() == [@test_game_name]
      assert :ok = Games.stop_game(@test_game_name)
      assert Games.list_games() == []
    end
  
    def dummy_callback(_, _, _), do: :ok 

  end

end
