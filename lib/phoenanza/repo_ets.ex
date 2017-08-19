defmodule Phoenanza.Repo.ETS do
  use GenServer
  # @behaviour Ecto.Repo
  require Logger

  alias Phoenanza.Players.User

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    Logger.info("Starting Phoenanza.Repo")
    :ets.new(User, [:set, :public, :named_table, read_concurrency: true])
    {:ok, opts}
  end

  def all(User) do
    for {_, user} <- :ets.tab2list(User) do user end
  end

  def get!(User, id) do
    case :ets.lookup(User, id) do
      [{^id, one}] -> one
      []    -> raise Ecto.NoResultsError, queryable: User
      other -> raise Ecto.MultipleResultsError, queryable: User, count: length(other)
    end
  end

  def insert(%Ecto.Changeset{data: %User{}, valid?: true} = cs) do
    newUser = apply_changeset(cs)
    :ets.insert(User, {newUser.id, newUser})
    {:ok, newUser}
  end
  def insert(cs) do
    {:error, cs}
  end

  def update(%Ecto.Changeset{data: %User{}, valid?: true} = cs) do
    newUser = apply_changeset(cs)
    :ets.update_element(User, newUser.id, {2, newUser})
    {:ok, newUser}    
  end
  def update(cs) do
    {:error, cs}
  end

  def delete(%User{id: id} = user) do
    :ets.delete(User, id)
    {:ok, user}
  end

  defp apply_changeset(%Ecto.Changeset{changes: changesMap, data: user}) do
    Map.merge(user, changesMap)
    |> check_id
  end

  defp check_id(%User{id: nil, name: name} = user) do
    %User{user | id: name}
  end
  defp check_id(user) do
    user
  end

    


end
