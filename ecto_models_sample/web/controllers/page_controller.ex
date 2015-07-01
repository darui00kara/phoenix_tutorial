defmodule EctoModelsSample.PageController do
  use EctoModelsSample.Web, :controller

  plug :action

  def index(conn, _params) do
    render conn, "index.html"
  end
end
