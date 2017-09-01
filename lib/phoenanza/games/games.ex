defmodule Phoenanza.Games do
  alias Phoenanza.Players
  alias Phoenanza.Games.Game
  alias Phoenanza.Repo.ETSCache
  

  def join_game(gameId, playerId, callback) do
    %Game{sup_pid: pid, game_pid: gamePid, players: players} = game = ETSCache.get_game(gameId)
    player = Players.get_user!(playerId)
    {:ok, playerPid} = ExBeans.Game.Supervisor.new_player(pid, player.name)
    :ok = ExBeans.Player.join_game(playerPid, gamePid, callback)
    ETSCache.update_game(%Game{game | players: [{playerId, player, playerPid} | players]})

    {:ok, playerPid}
   
  end

  def new_game(gameId) do
    case ETSCache.get_game(gameId) do
      {:error, :not_found} ->
        [sup: supPid, game: gamePid] = ExBeans.Games.Supervisor.start_game(gameId)
        newGame = %Game{id: gameId, sup_pid: supPid, game_pid: gamePid}
        ETSCache.insert(newGame)
      game ->
        {:ok, game}
    end
  end


end