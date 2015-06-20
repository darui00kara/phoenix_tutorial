defmodule DemoApp.PageController do
  use DemoApp.Web, :controller

  plug :action

  def index(conn, _params) do
    render conn, "index.html"
  end
end
