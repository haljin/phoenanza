defmodule PhoenanzaWeb.LobbyChannelTest do
  use PhoenanzaWeb.ChannelCase
  require Logger

  alias Phoenanza.Players
  alias Phoenanza.Games
  alias PhoenanzaWeb.UserSocket
  alias PhoenanzaWeb.LobbyChannel  

  @valid_attrs %{name: "some name"}
  @test_msg "test msg"
  @test_game_name "testGame"

  setup do    
    Players.clear_cache()
    Games.clear_cache()
    :ok
  end

  test "Join the lobby channel" do
    user = user_fixture()
    name = user.name
    assert {:ok, s} = connect(UserSocket, %{"token" => user.id})
    assert {:ok, _, _s} = subscribe_and_join(s, LobbyChannel, "room:lobby", %{})
    assert_broadcast "chat_list", %{users: [^name]}
    assert_broadcast "game_list", %{games: []}
  end
  
  test "Send a chat message" do
    user = user_fixture()
    s = make_new_lobby_socket(user)
    
    push s, "new_msg", %{"body" => @test_msg}
    msgWithName = user.name <> ": " <> @test_msg
    assert_broadcast "new_msg", %{body: ^msgWithName}
  end
  
  test "Create a game" do
    user = user_fixture()
    s = make_new_lobby_socket(user)
    
    push s, "create_game", %{"gameName" => @test_game_name}
    assert_broadcast "game_list", %{games: [@test_game_name]}
  end
  
  test "User list is being update when users come and go" do
    user = user_fixture()
    otherUser = user_fixture(%{name: "other name"})
    name = user.name
    otherName = otherUser.name
    
    _ = make_new_lobby_socket(user)
    assert_broadcast "chat_list", %{users: [^name]}
    
    newS = make_new_lobby_socket(otherUser)
    assert_broadcast "chat_list", %{users: userList}
    assert (name in userList) and (otherName in userList)

    close(newS)
    assert_broadcast "chat_list", %{users: [^name]}
  end


  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs 
      |> Enum.into(@valid_attrs)
      |> Players.create_user()
    user
  end

  defp make_new_lobby_socket(user) do
    {:ok, _, socket} =
    socket(nil, %{user: user}) |>
    subscribe_and_join(LobbyChannel, "room:lobby", %{})
    socket
  end

end
