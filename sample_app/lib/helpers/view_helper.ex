defmodule SampleApp.Helpers.ViewHelper do
  alias SampleApp.User
  alias SampleApp.Gravatar

  def current_user(conn) do
    conn.assigns[:current_user]
  end

  def current_user?(conn, %SampleApp.User{id: id}) do
    user = SampleApp.Repo.get(SampleApp.User, id)
    conn.assigns[:current_user] == user
  end

  def get_gravatar_url(%User{email: email}) do
    Gravatar.get_gravatar_url(email, 50)
  end
end