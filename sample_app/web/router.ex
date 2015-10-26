defmodule SampleApp.Router do
  use SampleApp.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SampleApp do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/home", StaticPagesController, :home
    get "/help", StaticPagesController, :help
    get "/about", StaticPagesController, :about
    get "/contact", StaticPagesController, :contact
    get "/signup", UserController, :new
    resources "/user", UserController, except: [:new]
    get "/signin", SessionController, :new
    post "/session", SessionController, :create
    delete "/signout", SessionController, :delete
    resources "/post", MicropostController, only: [:create, :delete]
    get "user/:id/following", UserController, :following
    get "user/:id/followers", UserController, :followers
    resources "/relationship", RelationshipController, only: [:create, :delete]
  end

  # Other scopes may use custom stacks.
  # scope "/api", SampleApp do
  #   pipe_through :api
  # end
end
