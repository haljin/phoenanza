defmodule PhoenanzaWeb.LobbyChannel do
    use Phoenix.Channel
    require Logger
  
    def join("room:lobby", _message, socket) do
      {:ok, socket}
    end
    def join("room:" <> _private_room_id, _params, _socket) do
      {:error, %{reason: "unauthorized"}}
    end

    def handle_in("new_msg", %{"body" => body}, socket) do
      Logger.debug("IN #{inspect socket}")
      user = socket.assigns.user
      broadcast! socket, "new_msg", %{body: user.name <> ": " <> body}
      {:noreply, socket}
    end
  
    def handle_out("new_msg", payload, socket) do
      push socket, "new_msg", payload
      {:noreply, socket}
    end
  end