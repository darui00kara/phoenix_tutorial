defmodule SampleApp.PageController do
  use SampleApp.Web, :controller

  plug SampleApp.Plugs.CheckAuthentication

  def index(conn, _params) do
    render conn, "index.html"
  end
end
