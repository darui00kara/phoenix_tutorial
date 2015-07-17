defmodule SampleApp.SessionController do
  use SampleApp.Web, :controller

  plug SampleApp.Plugs.CheckAuthentication
  plug :action

  def new(conn, _params) do
    render conn, "login_form.html"
  end

  def create(conn, %{"login_params" => %{"email" => email, "password" => password}}) do
    case login(email, password) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User login is success!!")
        |> put_session(:user_id, user.id)
        |> redirect(to: static_pages_path(conn, :home))
      :error ->
        conn
        |> put_flash(:error, "User login is failed!! email or password is incorrect.")
        |> redirect(to: session_path(conn, :new))
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logout now! See you again!!")
    |> delete_session(:user_id)
    |> redirect(to: static_pages_path(conn, :home))
  end

  def login(email, password) do
    user = SampleApp.User.find_user_from_email(email)
    case authentication(user, password) do
      true -> {:ok, user}
         _ -> :error
    end
  end

  def authentication(user, password) do
    case user do
      nil -> false
        _ -> Safetybox.is_decrypted(password, user.password_digest)
    end
  end
end