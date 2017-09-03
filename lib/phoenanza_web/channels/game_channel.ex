defmodule PhoenanzaWeb.GameChannel do
    use Phoenix.Channel
    require Logger

    alias Phoenanza.Games
    
    intercept ["player_joined", "field_update"]

    def join("game:" <> gameName, _message, socket) do
      case Games.find_game(gameName) do
        {:error, _} -> 
          {:error, %{reason: "Invalid game"}}
        _game ->          
          send(self(), {:after_join, gameName})
          {:ok, socket}          
      end
    end

    def handle_info({:after_join, gameName}, socket) do
      user = socket.assigns.user
      case Games.join_game(gameName, user.id, &PhoenanzaWeb.GameChannel.player_callback(socket, &1, &2, &3)) do
        {:ok, playerPid} ->  
          push socket, "game_joined", %{gameName: gameName}
          game = Games.find_game(gameName)
          ExBeans.BeanGame.set_callback(game.game_pid, &PhoenanzaWeb.GameChannel.game_callback(socket, &1, &2))
          broadcast! socket, "player_joined", %{players: game.players}
          {:noreply,  Phoenix.Socket.assign(Phoenix.Socket.assign(socket, :player,  playerPid), :game, gameName)}
        {:error, :game_full} ->
          push socket, "game_leave", %{reason: "Game is full!"}
          {:stop, {:shutdown, :game_full}, socket}
      end    
    end

    def handle_in("plant_bean", %{"index" => index}, socket) do
      playerPid = socket.assigns.player
      case ExBeans.Player.play_card(playerPid, index) do
        :ok -> 
          newHand = ExBeans.Player.see_hand(playerPid)
          newField = ExBeans.Player.see_fields(playerPid)
          push socket, "state", %{hand: newHand, field: newField}
          broadcast! socket, "field_update", %{user: socket.assigns.user.id, field: newField}
        {:error, _} ->
          push socket, "illegal_move", %{}        
      end      
      {:noreply, socket}
    end  
    def handle_in("discard_card", %{"index" => index}, socket) do
      playerPid = socket.assigns.player
      case ExBeans.Player.discard_card(playerPid, index) do
        :ok -> 
          newHand = ExBeans.Player.see_hand(playerPid)
          newField = ExBeans.Player.see_fields(playerPid)
          push socket, "state", %{hand: newHand, field: newField}
        {:error, _} ->
          push socket, "illegal_move", %{}        
      end      
      {:noreply, socket}
    end  
    def handle_in("player_pass", %{}, socket) do
      playerPid = socket.assigns.player
      unless :ok ==  ExBeans.Player.pass(playerPid) do
          push socket, "illegal_move", %{}        
      end      
      {:noreply, socket}
    end  

    def handle_out("player_joined", %{players: players}, socket) do
      with [{_, otherPlayer, _}] <- List.keydelete(players, socket.assigns.user.id, 0) do
        Logger.debug("Sending player_joined with #{inspect otherPlayer.name}")
        push socket, "player_joined", %{player: otherPlayer.name}
      end
      {:noreply, socket}
    end
    def handle_out("field_update", %{user: id, field: field}, socket) do
      if id != socket.assigns.user.id do
        push socket, "field_update", %{field: field}
      end
      {:noreply, socket}
    end


    def player_callback(socket, state, hand, field) do
      push socket, "state", %{state: state, hand: hand, field: field}
      Logger.debug("Msg from game now in state #{inspect state} hand #{inspect hand} field #{inspect field}")
      :ok
    end

    def game_callback(socket, :new_mid_cards, data) do
      broadcast! socket, "mid_cards", %{cards: data}      
    end
    def game_callback(socket, :new_discards, data) do
      for card <- Enum.reverse(data) do 
        broadcast! socket, "discard", %{card: card}
      end
    end
    
    def terminate({:shutdown, :game_full}, socket) do
      Logger.debug("GameChannel closed for #{inspect socket.assigns.user.name} - full game")
    end 
    def terminate(msg, socket) do
      # TODO: Consider not stopping when the player quits and allow resuming of games
      Logger.debug("terminate #{inspect msg}")
      Logger.debug("GameChannel closed for #{inspect socket.assigns.user.name}")
      Games.stop_game(socket.assigns.game)
      broadcast! socket, "game_ended", %{}
    end  

    
  end