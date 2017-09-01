defmodule PhoenanzaWeb.LobbyChannel do
    use Phoenix.Channel
    require Logger

    alias Phoenanza.Players
    alias Phoenanza.Players.User

    def join("room:lobby", _message, socket) do
      send(self(), :after_join)
      {:ok, socket}
    end
    def join("room:" <> _private_room_id, _params, _socket) do
      {:error, %{reason: "unauthorized"}}
    end

    def handle_info(:after_join, socket) do
      allInChat = for %User{name: name} <- Players.list_users_in_cache() do name end 
      broadcast! socket, "chat_list", %{users: allInChat}  
      {:noreply, socket}   
    end

    def handle_in("new_msg", %{"body" => body}, socket) do
      Logger.debug("IN #{inspect socket}")
      user = socket.assigns.user
      broadcast! socket, "new_msg", %{body: user.name <> ": " <> body}
      {:noreply, socket}
    end    
    def handle_in("new_game", %{"id" => playerId, "gameName" => game}, socket) do


      {:noreply, socket}
    end  
    
    def terminate(_msg, socket) do
      Logger.debug("Socket closed for #{inspect socket.assigns.user}")
      user = socket.assigns.user   
      Players.decache_user(user) 
      allInChat = for %User{name: name} <- Players.list_users_in_cache() do name end 
      broadcast! socket, "chat_list", %{users: allInChat}  
    end    
  end