defmodule SampleApp.UserController do
  use SampleApp.Web, :controller

  plug :action

  def new(conn, _params) do
    changeset = SampleApp.User.changeset(%SampleApp.User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = SampleApp.User.changeset(%SampleApp.User{}, user_params)

    if changeset.valid? do
      Repo.insert(changeset)

      conn
      |> put_flash(:info, "User registration is success!!")
      |> redirect(to: static_pages_path(conn, :home))
    else
      render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get(SampleApp.User, id)
    render(conn, "show.html", user: user)
  end

  def authentication(email, password) do
    user = Repo.get(SampleApp.User, email)
    Safetybox.is_decrypted(password, user.password_digest)
  end
end