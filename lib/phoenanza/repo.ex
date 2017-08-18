defmodule Phoenanza.Repo do
  use Ecto.Repo, otp_app: :phoenanza
  require Logger

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    Logger.info("Starting Phoenanza.Repo")
    {:ok, opts}
  end
end
