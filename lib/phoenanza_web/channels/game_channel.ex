defmodule PhoenanzaWeb.GameChannel do
    use Phoenix.Channel
    require Logger

    alias Phoenanza.Players
    alias Phoenanza.Players.User
    alias Phoenanza.Games

    def join("game:" <> gameName, _message, socket) do
      case Games.find_game(gameName) do
        {:error, _} -> 
          {:error, %{reason: "wrong game name"}}
        game ->           
          user = socket.assigns.user
          {_, _, playerPid}  = List.keyfind(game.players, user.id, 0)
          {:ok, Phoenix.Socket.assign(Phoenix.Socket.assign(socket, :game, gameName), :player,  playerPid)}
      end
    end
   
    def handle_in("new_game", %{"id" => playerId, "gameName" => gameName}, socket) do
      {:noreply, socket}
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