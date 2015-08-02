defmodule SampleApp.MicropostController do
  use SampleApp.Web, :controller

  plug SampleApp.Plugs.CheckAuthentication
  plug SampleApp.Plugs.SignedInUser
  plug :scrub_params, "micropost" when action in [:create]
  plug :action

  def create(conn, %{"micropost" => micropost_params}) do
    changeset = SampleApp.Micropost.changeset(%SampleApp.Micropost{}, micropost_params)

    if changeset.valid? do
      Repo.insert(changeset)
      conn = put_flash(conn, :info, "Post successfully!!")
    else
      conn = put_flash(conn, :error, "Post failed!!")
    end

    action = "#{user_path(conn, :show, conn.assigns[:current_user].id)}?select_page=1"
    redirect(conn, to: action)
  end

  def delete(conn, %{"id" => id}) do
    micropost = Repo.get(SampleApp.Micropost, id)
    Repo.delete(micropost)

    action = "#{user_path(conn, :show, conn.assigns[:current_user].id)}?select_page=1"

    conn
    |> put_flash(:info, "Micropost deleted successfully.")
    |> redirect(to: action)
  end
end