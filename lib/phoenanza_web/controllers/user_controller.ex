defmodule PhoenanzaWeb.UserController do
  use PhoenanzaWeb, :controller
  require Logger

  alias Phoenanza.Players
  alias Phoenanza.Players.User

  action_fallback PhoenanzaWeb.FallbackController

  def index(conn, _params) do
    users = Players.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    Logger.debug("USER CONTROLLER #{inspect user_params}")
    with {:ok, %User{} = user} <- Players.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json", user: user)    
    end
  end

  def show(conn, %{"name" => name} = data) do
    Logger.debug("Getting the user by name")
    case Players.get_user_by_name(name) do
      nil -> {:error, :not_found}
      existingUser -> render(conn, "show.json", user: existingUser)
    end    
  end
  def show(conn, %{"id" => id}) do
    user = Players.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Players.get_user!(id)

    with {:ok, %User{} = user} <- Players.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Players.get_user!(id)
    with {:ok, %User{}} <- Players.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
