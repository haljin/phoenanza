defmodule PhoenanzaWeb.GameChannel do
    use Phoenix.Channel
    require Logger

    alias Phoenanza.Players
    alias Phoenanza.Players.User
    alias Phoenanza.Games

    def join("game:" <> _gameName, _message, socket) do
      # TODO: Deny connection if the game was not created yet
      {:ok, socket}
    end
   
    def handle_in("new_game", %{"id" => playerId, "gameName" => gameName}, socket) do
      user = socket.assigns.user
      Logger.debug("User #{inspect user.name} is starting a game")
      {:ok, _game} = Games.new_game(gameName)
      # TODO: Send a fail response if joining fails, move the game creation to lobby channel
      {:ok, playerPid} = Games.join_game(gameName, playerId, &PhoenanzaWeb.GameChannel.player_callback/3)      

      {:noreply, Phoenix.Socket.assign(Phoenix.Socket.assign(socket, :game, gameName), :player,  playerPid)}
    end  

    def player_callback(state, hand, field) do
      Logger.debug("Msg from game now in state #{inspect state} hand #{inspect hand} field #{inspect field}")
      :ok
    end
    
    def terminate(msg, socket) do
      # TODO: Consider not stopping when the player quits and allow resuming of games
      Logger.debug("GameChannel.terminate with #{inspect msg}")
      Games.stop_game(socket.assigns.game)
      broadcast! socket, "game_ended", %{}
    end  

    
  end