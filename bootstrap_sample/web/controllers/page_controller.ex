defmodule BootstrapSample.PageController do
  use BootstrapSample.Web, :controller

  plug :action

  def index(conn, _params) do
    render conn, "index.html"
  end

  def sample(conn, _params) do
    render conn, "sample.html"
  end
end
