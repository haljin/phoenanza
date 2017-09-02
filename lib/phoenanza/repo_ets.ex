defmodule Phoenanza.Repo.ETSCache do
  @moduledoc """
  ETS cache for storing temporary information and fast access. The cache stores information on currently active users and 
  currently played games.
  """
  use GenServer
  require Logger

  alias Phoenanza.Players.User
  alias Phoenanza.Games.Game

#  ---------------------------- API ----------------------------
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end 

  @doc "Insert a data structure into the ETS cache"
  @spec insert(%User{} | %Game{}) :: {:ok, %User{}} | {:ok, %Game{}}
  def insert(%User{} = newUser) do
    :ets.insert(User, {newUser.id, newUser})
    {:ok, newUser}
  end  
  def insert(%Game{} = newGame) do
    :ets.insert(Game, {newGame.id, newGame})
    {:ok, newGame}
  end
#  -------------------------- User Cache ------------------------
  @doc "List all users in the cache"
  @spec list_users() :: [%User{}]
  def list_users() do
    all(User)
  end

  @doc "Retrieves a user by id from the cache"
  @spec get_user!(integer) :: %User{}
  def get_user!(id) do
    get!(User, id)
  end

  @doc "Update the user in the cache"
  @spec update_user(%User{}) :: {:ok, %User{}}
  def update_user(user) do
    update(user)
  end

  @doc "Deletes the specified user"
  @spec delete_user(%User{}) :: {:ok, %User{}}
  def delete_user(user) do
    delete(user)
  end

  @doc "Deletes all users in the cache"
  @spec delete_all_users() :: true
  def delete_all_users() do
    delete_all(User)
  end

#  -------------------------- Game Cache ------------------------
  @doc "List all games in the cache"
  @spec list_games() :: [%Game{}]
  def list_games() do
    all(Game)
  end

  @doc "Retrieves a game by id from the cache"
  @spec get_game(integer) :: %Game{}
  def get_game(id) do
    get(Game, id)
  end
  
  @doc "Update the game in the cache"
  @spec update_game(%Game{}) :: {:ok, %Game{}}
  def update_game(game) do
    update(game)
  end

  @doc "Deletes the specified game"
  @spec delete_game(%Game{}) :: {:ok, %Game{}}
  def delete_game(game) do
    delete(game)
  end

#  ---------------------- GenServer Callbacks -------------------
  def init(opts) do
    Logger.info("Starting Phoenanza.Repo")
    :ets.new(User, [:set, :public, :named_table, read_concurrency: true])
    :ets.new(Game, [:set, :public, :named_table, read_concurrency: true])
    {:ok, opts}
  end
#  ----------------- Generic internal functions -----------------

  defp all(tab) do
    for {_, entry} <- :ets.tab2list(tab) do entry end
  end
  
  defp get(tab, id) do
    case :ets.lookup(tab, id) do
      [{^id, one}] -> one
      [] -> {:error, :not_found}
    end
  end

  defp get!(tab, id) do
    case :ets.lookup(tab, id) do
      [{^id, one}] -> one
    end
  end

  defp update(%User{} = newUser) do
    :ets.update_element(User, newUser.id, {2, newUser})
    {:ok, newUser}    
  end
  defp update(%Game{} = newGame) do
    :ets.update_element(Game, newGame.id, {2, newGame})
    {:ok, newGame}    
  end

  defp delete(%User{id: id} = user) do
    :ets.delete(User, id)
    {:ok, user}
  end
  defp delete(%Game{id: id} = game) do
    :ets.delete(Game, id)
    {:ok, game}
  end

  defp delete_all(tab) do
    :ets.delete_all_objects(tab)
  end
end
