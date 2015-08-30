defmodule SampleApp.SessionController do
  use SampleApp.Web, :controller

  import SampleApp.Signin

  plug SampleApp.Plugs.CheckAuthentication
  plug :action

  def new(conn, _params) do
    render conn, "signin_form.html"
  end

  def create(conn, %{"signin_params" => %{"email" => email, "password" => password}}) do
    case sign_in(email, password) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User sign-in is success!!")
        |> put_session(:user_id, user.id)
        |> redirect(to: static_pages_path(conn, :home))
      :error ->
        conn
        |> put_flash(:error, "User sign-in is failed!! email or password is incorrect.")
        |> redirect(to: session_path(conn, :new))
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Sign-out now! See you again!!")
    |> delete_session(:user_id)
    |> redirect(to: static_pages_path(conn, :home))
  end
end