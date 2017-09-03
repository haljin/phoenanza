defmodule Phoenanza.Games do
  alias Phoenanza.Players
  alias Phoenanza.Games.Game
  alias Phoenanza.Repo.ETSCache
  

  @doc "Create a new game with specified name or returns the cached game if it exists."
  @spec new_game(Game.id) :: {:ok, %Game{}}
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

  @doc "Join the specified game as the player with the specified id."
  @spec join_game(Game.id, integer, ExBeans.Player.player_callback) :: {:ok, pid} | {:error, :game_full}
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

  @doc "Find the game in the cache by id."
  @spec find_game(Game.id) :: %Game{}
  def find_game(gameId) do
    ETSCache.get_game(gameId)
  end

  @doc "List all games being currently played."
  @spec list_games() :: [%Game{}]
  def list_games() do
    for %Game{id: name} <- ETSCache.list_games() do name end     
  end

  @doc "Stop the gave with the given id."
  @spec stop_game(Game.id) :: :ok
  def stop_game(gameId) do
    with %Game{sup_pid: pid} = game <- ETSCache.get_game(gameId) do
      ETSCache.delete_game(game)
      ExBeans.Games.Supervisor.stop_game(pid)      
    end
  end

  @doc "Clears the Game cache."
  def clear_cache() do
    ETSCache.delete_all_games()
  end
end