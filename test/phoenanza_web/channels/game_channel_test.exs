defmodule PhoenanzaWeb.GameChannelTest do
  use PhoenanzaWeb.ChannelCase
  require Logger

  alias Phoenanza.Players
  alias Phoenanza.Games
  alias PhoenanzaWeb.GameChannel  

  @valid_attrs %{name: "some name"}
  @test_game_name "testGame"

  setup do    
    Players.clear_cache()
    Games.clear_cache()
    :ok
  end

  test "Joing the game channel" do
    %{id: id} = user = user_fixture()
    
    _ = Games.new_game(@test_game_name)
    _s = make_new_game_socket(user, @test_game_name)
    assert_push "game_joined", %{gameName: @test_game_name}
    assert_broadcast "player_joined", %{players: [{^id, _, _}]}
  end
  
  test "Only two can play that game" do
    user = user_fixture()
    otherUser = user_fixture(%{name: "other name"})
    invalidUser = user_fixture(%{name: "bad user"})
    
    _ = Games.new_game(@test_game_name)
    _s = make_new_game_socket(user, @test_game_name)
    assert_push "game_joined", %{gameName: @test_game_name}
    _s2 = make_new_game_socket(otherUser, @test_game_name)
    assert_push "game_joined", %{gameName: @test_game_name}

    Process.flag(:trap_exit, true)
    socket = socket(nil, %{user: invalidUser}) 
    catch_exit subscribe_and_join(socket, GameChannel, "game:" <> @test_game_name, %{}) 
    
    assert_push "game_leave", %{reason: "Game is full!"}
  end
  
  test "Can only join channels for games that exist" do
    user = user_fixture()
    socket = socket(nil, %{user: user}) 
    assert {:error, %{reason: "Invalid game"}} =  subscribe_and_join(socket, GameChannel, "game:" <> @test_game_name, %{}) 
  end


  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs 
      |> Enum.into(@valid_attrs)
      |> Players.create_user()
    user
  end

  defp make_new_game_socket(user, gameName) do
    {:ok, _, socket} =
    socket(nil, %{user: user}) |>
    subscribe_and_join(GameChannel, "game:" <> gameName, %{})
    socket
  end

end
