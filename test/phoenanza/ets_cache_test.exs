defmodule Phoenanza.ETSCacheTest do
  use ExUnit.Case
  require Logger

  alias Phoenanza.Players.User
  alias Phoenanza.Games.Game
  alias Phoenanza.Repo.ETSCache
  
  describe "User Cache" do

    @valid_attrs %{id: 1, name: "some name"}
    @second_user_attrs %{id: 2, name: "some other name"}
    @update_attrs %{id: 1, name: "some updated name"}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} = 
        attrs 
        |> Enum.into(@valid_attrs)
        |> create_user
        |> ETSCache.insert
      user
    end

    setup do 
      :ets.delete_all_objects(User)
      :ok
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert ETSCache.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert ETSCache.get_user!(user.id) == user
    end

    test "update_user/2 updates the user" do
      newUser = create_user(@update_attrs)
      assert {:ok, newUser} = ETSCache.update_user(newUser)
      assert %User{} = newUser
      assert newUser.name == "some updated name"
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = ETSCache.delete_user(user)
      assert_raise CaseClauseError, fn -> ETSCache.get_user!(user.id) end
    end

    test "delete_all_users/0 clears the cache" do
      _user = user_fixture()
      _user2 = user_fixture(@second_user_attrs)
      assert ETSCache.delete_all_users()
      assert ETSCache.list_users() == []
    end
  end

  describe "Game Cache" do
    
    @valid_attrs %{id: "a game"}
    @update_attrs %{id: "a game", players: [:a, :b]}

    def game_fixture(attrs \\ %{}) do
      {:ok, game} = 
        attrs 
        |> Enum.into(@valid_attrs)
        |> create_game
        |> ETSCache.insert
      game
    end

    setup do 
      :ets.delete_all_objects(Game)
      :ok
    end

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert ETSCache.list_games() == [game]
    end

    test "get_game/1 returns the game with given id" do
      game = game_fixture()
      assert ETSCache.get_game(game.id) == game
    end
    
    test "get_game/1 returns error if the game is not in the cache" do
      assert ETSCache.get_game("no such game") == {:error, :not_found}
    end

    test "update_game/2 updates the game" do
      newGame = create_game(@update_attrs)
      assert {:ok, newGame} = ETSCache.update_game(newGame)
      assert %Game{} = newGame
      assert newGame.players == [:a, :b]
    end

    test "delete_game/1 deletes the user" do
      game = game_fixture()
      assert {:ok, %Game{}} = ETSCache.delete_game(game)
      assert ETSCache.get_game(game.id) == {:error, :not_found}
    end
  end

  
  defp create_user(changesMap) do
    Map.merge(%User{}, changesMap)
  end

  defp create_game(changesMap) do
    Map.merge(%Game{}, changesMap)
  end
end
