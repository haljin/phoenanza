defmodule PhoenanzaWeb.LobbyChannel do
    use Phoenix.Channel
    require Logger

    alias Phoenanza.Players
    alias Phoenanza.Players.User
    alias Phoenanza.Games

    def join("room:lobby", _message, socket) do
      {:ok, _userInfo} = Players.cache_user(socket.assigns.user)
      send(self(), :after_join)
      {:ok, socket}
    end
    def join("room:" <> _private_room_id, _params, _socket) do
      {:error, %{reason: "unauthorized"}}
    end

    def handle_info(:after_join, socket) do
      allInChat = for %User{name: name} <- Players.list_users_in_cache() do name end 
      broadcast! socket, "chat_list", %{users: allInChat}  
      broadcast! socket, "game_list", %{games: Games.list_games()}  
      {:noreply, socket}   
    end

    def handle_in("new_msg", %{"body" => body}, socket) do
      user = socket.assigns.user
      broadcast! socket, "new_msg", %{body: user.name <> ": " <> body}
      {:noreply, socket}
    end    
    def handle_in("join_game", %{"id" => playerId, "gameName" => gameName}, socket) do
      user = socket.assigns.user
      Logger.debug("User #{inspect user.name} is starting a game")
      {:ok, _game} = Games.new_game(gameName)      
      broadcast! socket, "game_list", %{games: Games.list_games()}  
      case Games.join_game(gameName, playerId, &PhoenanzaWeb.GameChannel.player_callback/3) do
        {:ok, _playerPid} ->  
          push socket, "game_joined", %{"gameName" => gameName}
          {:noreply, socket}
        {:error, :game_full} ->
          push socket, "error", %{"message" => "Game is full!"}
          {:noreply, socket}
      end     
    end  
    
    def terminate(_msg, socket) do
      Logger.debug("Socket closed for #{inspect socket.assigns.user}")
      user = socket.assigns.user   
      Players.decache_user(user) 
      allInChat = for %User{name: name} <- Players.list_users_in_cache() do name end 
      broadcast! socket, "chat_list", %{users: allInChat}  
    end    
  end