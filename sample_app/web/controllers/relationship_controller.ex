defmodule SampleApp.RelationshipController do
  use SampleApp.Web, :controller

  plug SampleApp.Plugs.CheckAuthentication
  plug SampleApp.Plugs.SignedInUser
  plug :action

  def create(conn, params) do
    if SampleApp.Relationship.follow!(params["id"], params["follow_id"]) do
      conn = put_flash(conn, :info, "Follow successfully!!")
    else
      conn = put_flash(conn, :error, "Follow failed!!")
    end

    redirect(conn, to: static_pages_path(conn, :home))
  end

  def delete(conn, params) do
    SampleApp.Relationship.unfollow!(params["id"], params["unfollow_id"])

    conn
    |> put_flash(:info, "Unfollow successfully!!")
    |> redirect(to: static_pages_path(conn, :home))
  end
end