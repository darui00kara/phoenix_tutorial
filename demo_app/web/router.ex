defmodule DemoApp.Router do
  use DemoApp.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DemoApp do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController
    resources "/microposts", MicropostController
  end

  # Other scopes may use custom stacks.
  # scope "/api", DemoApp do
  #   pipe_through :api
  # end
end
