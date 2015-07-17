defmodule SampleApp.StaticPagesController do
  use SampleApp.Web, :controller

  plug SampleApp.Plugs.CheckAuthentication
  plug :action

  def home(conn, _params) do
    render conn, "home.html"
  end

  def help(conn, _params) do
    render conn, "help.html", message: "Help"
  end

  def about(conn, _params) do
    render conn, "about.html", message: "About"
  end

  def contact(conn, _params) do
    render conn, "contact.html"
  end
end
