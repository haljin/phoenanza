defmodule Phoenanza.Repo do
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
  




end
