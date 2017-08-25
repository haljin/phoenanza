defmodule PhoenanzaWeb.LobbyChannel do
    use Phoenix.Channel
    require Logger

    alias Phoenanza.Repo.ETSCache
    alias Phoenanza.Players.User

    def join("room:lobby", _message, socket) do
      send(self(), :after_join)
      {:ok, socket}
    end
    def join("room:" <> _private_room_id, _params, _socket) do
      {:error, %{reason: "unauthorized"}}
    end

    def handle_info(:after_join, socket) do
      allInChat = for %User{name: name} <- ETSCache.list_users() do name end 
      broadcast! socket, "chat_list", %{users: allInChat}  
      {:noreply, socket}   
    end

    def handle_in("new_msg", %{"body" => body}, socket) do
      Logger.debug("IN #{inspect socket}")
      user = socket.assigns.user
      broadcast! socket, "new_msg", %{body: user.name <> ": " <> body}
      {:noreply, socket}
    end   
    
    def terminate(_msg, socket) do
      user = socket.assigns.user
      ETSCache.delete_user(user)     
      allInChat = for %User{name: name} <- ETSCache.list_users() do name end 
      broadcast! socket, "chat_list", %{users: allInChat}  
    end    
  end