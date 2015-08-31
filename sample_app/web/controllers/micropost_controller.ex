defmodule SampleApp.MicropostController do
  use SampleApp.Web, :controller

  plug SampleApp.Plugs.CheckAuthentication
  plug SampleApp.Plugs.SignedInUser
  plug :scrub_params, "micropost" when action in [:create]

  def create(conn, %{"micropost" => micropost_params}) do
    changeset = SampleApp.Micropost.changeset(%SampleApp.Micropost{}, micropost_params)

    if changeset.valid? do
      Repo.insert(changeset)
      conn = put_flash(conn, :info, "Post successfully!!")
    else
      conn = put_flash(conn, :error, "Post failed!!")
    end

    redirect(conn, to: user_path(conn, :show, conn.assigns[:current_user]))
  end

  def delete(conn, %{"id" => id}) do
    micropost = Repo.get(SampleApp.Micropost, id)
    Repo.delete(micropost)

    conn
    |> put_flash(:info, "Micropost deleted successfully.")
    |> redirect(to: user_path(conn, :show, conn.assigns[:current_user]))
  end
end