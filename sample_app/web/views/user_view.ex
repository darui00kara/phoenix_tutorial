defmodule SampleApp.UserView do
  use SampleApp.Web, :view
  alias SampleApp.User

  def get_gravatar_url(%User{email: email}) do
    gravatar_id = email |> email_downcase |> email_crypt_md5
    "https://secure.gravatar.com/avatar/#{gravatar_id}?s=50"
  end

  def email_crypt_md5(email) do
    :erlang.md5(email)
    |> :erlang.bitstring_to_list
    |> Enum.map(&(:io_lib.format("~2.16.0b", [&1])))
    |> List.flatten
    |> :erlang.list_to_bitstring
  end

  def email_downcase(email) do
    String.downcase(email)
  end
end