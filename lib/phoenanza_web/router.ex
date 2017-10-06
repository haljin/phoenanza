defmodule PhoenanzaWeb.Router do
  use PhoenanzaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug CORSPlug, [origin: "*"]
    plug :accepts, ["json"]
  end

  scope "/", PhoenanzaWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", PhoenanzaWeb do
    pipe_through :api

    resources "/users", UserController, except: [:edit]
    options "/users", UserController, :options
  end
end
