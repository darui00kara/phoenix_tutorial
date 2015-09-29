defmodule SampleApp.RelationshipController do
  use SampleApp.Web, :controller

  plug SampleApp.Plugs.CheckAuthentication
  plug SampleApp.Plugs.SignedInUser

  def create(conn, params) do
    SampleApp.Relationship.follow!(params["id"], params["follow_id"])

    conn
    |> put_flash(:info, "Follow successfully!!")
    |> redirect(to: user_path(conn, :show, params["follow_id"]))
  end

  def delete(conn, params) do
    SampleApp.Relationship.unfollow!(params["id"], params["unfollow_id"])

    conn
    |> put_flash(:info, "Unfollow successfully!!")
    |> redirect(to: user_path(conn, :show, params["unfollow_id"]))
  end
end