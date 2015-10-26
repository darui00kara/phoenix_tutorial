defmodule SampleApp.Gravatar do
  def get_gravatar_url(email, size) do
    gravatar_id = email_to_gravator_id(email)
    "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
  end

  defp email_to_gravator_id(email) do
    email |> email_downcase |> email_crypt_md5
  end
  
  defp email_crypt_md5(email) do
    :erlang.md5(email)
    |> :erlang.bitstring_to_list
    |> Enum.map(&(:io_lib.format("~2.16.0b", [&1])))
    |> List.flatten
    |> :erlang.list_to_bitstring
  end

  defp email_downcase(email) do
    String.downcase(email)
  end
end