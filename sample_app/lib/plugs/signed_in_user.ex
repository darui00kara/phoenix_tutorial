defmodule SampleApp.Plugs.SignedInUser do
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  import SampleApp.Router.Helpers, only: [session_path: 2]

  def init(options) do
    options
  end

  def call(conn, _) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:info, "Please sign-in.")
      |> redirect(to: session_path(conn, :new))
      |> halt
    end
  end
end