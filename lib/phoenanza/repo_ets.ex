defmodule Phoenanza.Repo.ETSCache do
  use GenServer
  require Logger

  alias Phoenanza.Players.User

#  ---------------------------- API ----------------------------
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end 

  # @doc "Insert a data structure into the ETS cache"
  @spec insert(%User{}) :: {:ok, %User{}}
  def insert(%User{} = newUser) do
    :ets.insert(User, {newUser.id, newUser})
    {:ok, newUser}
  end
#  -------------------------- User Cache ------------------------
  # @doc "List all users in the cache"
  @spec list_users() :: [%User{}]
  def list_users() do
    all(User)
  end

  # @doc "Retrieves user by id from the cache"
  @spec get_user!(integer) :: %User{}
  def get_user!(id) do
    get!(User, id)
  end

  # @doc "Update the user in the cache"
  @spec update_user(%User{}) :: {:ok, %User{}}
  def update_user(user) do
    update(user)
  end

  # @doc "Deletes the specified user"
  @spec delete_user(%User{}) :: {:ok, %User{}}
  def delete_user(user) do
    delete(user)
  end


#  ---------------------- GenServer Callbacks -------------------
  def init(opts) do
    Logger.info("Starting Phoenanza.Repo")
    :ets.new(User, [:set, :public, :named_table, read_concurrency: true])
    {:ok, opts}
  end
#  ----------------- Generic internal functions -----------------

  defp all(User) do
    for {_, user} <- :ets.tab2list(User) do user end
  end

  defp get!(User, id) do
    case :ets.lookup(User, id) do
      [{^id, one}] -> one
    end
  end

  defp update(%User{} = newUser) do
    :ets.update_element(User, newUser.id, {2, newUser})
    {:ok, newUser}    
  end

  defp delete(%User{id: id} = user) do
    :ets.delete(User, id)
    {:ok, user}
  end
end
