defmodule Phoenanza.Players.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Phoenanza.Players.User

  defstruct name: "", id: nil


  @doc false
  def build(%User{} = user, %{"name" => name}) do
    %User{user | name: name, id: String.to_atom(name)}
  end
end
