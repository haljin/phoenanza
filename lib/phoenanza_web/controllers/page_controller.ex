defmodule PhoenanzaWeb.PageController do
  use PhoenanzaWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
