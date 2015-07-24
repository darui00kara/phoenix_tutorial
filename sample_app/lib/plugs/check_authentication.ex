defmodule SampleApp.Plugs.CheckAuthentication do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _) do
    user_id = get_session(conn, :user_id)
    if session_present?(user_id) do
      assign(conn, :current_user, SampleApp.Repo.get(SampleApp.User, user_id))
    else
      conn
    end
  end

  defp session_present?(user_id) do
    case user_id do
      nil -> false
      _   -> true
    end
  end
end