defmodule SampleApp.UserController do
  use SampleApp.Web, :controller

  plug SampleApp.Plugs.CheckAuthentication
  plug :action

  def new(conn, _params) do
    changeset = SampleApp.User.changeset(%SampleApp.User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = SampleApp.User.changeset(%SampleApp.User{}, user_params)

    if changeset.valid? do
      Repo.insert(changeset)

      user = SampleApp.User.find_user_from_email(user_params["email"])

      conn
      |> put_flash(:info, "User registration is success!!")
      |> put_session(:user_id, user.id)
      |> redirect(to: static_pages_path(conn, :home))
    else
      render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get(SampleApp.User, id)
    render(conn, "show.html", user: user)
  end
end