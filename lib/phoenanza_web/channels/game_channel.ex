defmodule PhoenanzaWeb.GameChannel do
    use Phoenix.Channel
    require Logger

    alias Phoenanza.Players
    alias Phoenanza.Players.User
    alias Phoenanza.Games

    def join("game:" <> _gameName, _message, socket) do
      {:ok, socket}
    end
   
    def handle_in("new_game", %{"id" => playerId, "gameName" => gameName}, socket) do
      user = socket.assigns.user
      Logger.debug("User #{inspect user.name} is starting a game")
      {:ok, _game} = Games.new_game(gameName)
      {:ok, playerPid} = Games.join_game(gameName, playerId, &PhoenanzaWeb.GameChannel.player_callback/3)


      {:noreply, Phoenix.Socket.assign(Phoenix.Socket.assign(socket, :game, gameName), :player,  playerPid)}
    end  

    def player_callback(state, hand, field) do
      Logger.debug("Msg from game now in state #{inspect state} hand #{inspect hand} field #{inspect field}")
      :ok
    end

    
  end