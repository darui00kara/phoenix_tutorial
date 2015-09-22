defmodule SampleApp.PageControllerTest do
  use SampleApp.ConnCase
  use Plug.Test

  @default_opts [
    store: :cookie,
    key: "foobar",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt"
  ]

  @secret String.duplicate("abcdef0123456789", 8)
  @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))

  test "GET /" do
    conn = Plug.Test.conn(:get, "/")
    
    conn = put_in(conn.secret_key_base, @secret)
           |> Plug.Session.call(@signing_opts)
           |> fetch_session
           |> put_session(:user_id, 1)

    session = get_session(conn, :user_id)
    assert session_present?(session) == true
  end

  defp session_present?(user_id) do
    case user_id do
      nil -> false
      _   -> true
    end
  end
end
