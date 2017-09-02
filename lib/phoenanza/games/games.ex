defmodule Phoenanza.Games do
  alias Phoenanza.Players
  alias Phoenanza.Games.Game
  alias Phoenanza.Repo.ETSCache
  

  def join_game(gameId, playerId, callback) do
    %Game{sup_pid: pid, game_pid: gamePid, players: players} = game = ETSCache.get_game(gameId)
    player = Players.get_user!(playerId)
    
    case ExBeans.Game.Supervisor.new_player(pid, player.name) do
      {:ok, playerPid} ->
        :ok = ExBeans.Player.join_game(playerPid, gamePid, callback)
        ETSCache.update_game(%Game{game | players: [{playerId, player, playerPid} | players]})
        {:ok, playerPid}
      _ ->
        {:error, :game_full}
    end
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

  def find_game(gameId) do
    ETSCache.get_game(gameId)
  end

  def list_games() do
    for %Game{id: name} <- ETSCache.list_games() do name end     
  end

  def stop_game(gameId) do
    with %Game{sup_pid: pid} = game <- ETSCache.get_game(gameId) do
      ETSCache.delete_game(game)
      ExBeans.Games.Supervisor.stop_game(pid)      
    end
  end
end