defmodule SampleApp.StaticPagesController do
  use SampleApp.Web, :controller

  plug :action

  def home(conn, _params) do
    render conn, "home.html", message: "Home"
  end

  def help(conn, _params) do
    render conn, "help.html", message: "Help"
  end

  def about(conn, _params) do
    render conn, "about.html", message: "About"
  end
end
