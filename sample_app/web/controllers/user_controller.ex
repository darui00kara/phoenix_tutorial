defmodule SampleApp.UserController do
  use SampleApp.Web, :controller

  plug :action

  def new(conn, _params) do
    render conn, "new.html"
  end

  def authentication(email, password) do
    user = Repo.get(User, email)
    Safetybox.is_decrypted(password, user.password_digest)
  end
end