defmodule SampleApp.UserController do
  use SampleApp.Web, :controller

  plug :action

  def new(conn, _params) do
    render conn, "new.html"
  end
end