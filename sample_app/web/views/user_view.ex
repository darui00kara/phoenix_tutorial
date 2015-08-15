defmodule SampleApp.UserView do
  use SampleApp.Web, :view
  alias SampleApp.User

  def get_gravatar_url(%User{email: email}) do
    gravatar_id = email |> email_downcase |> email_crypt_md5
    "https://secure.gravatar.com/avatar/#{gravatar_id}?s=50"
  end

  def get_previous_page_url(action, current_page) do
    get_page_url(action, current_page - 1)
  end

  def get_next_page_url(action, current_page) do
    get_page_url(action, current_page + 1)
  end

  def get_page_url(action, page_number) do
    "#{action}?select_page=#{page_number}"
  end

  def is_empty_list?(list) when is_list(list) do
    list == []
  end

  def following?(conn, follow_user_id) do
    SampleApp.Relationship.following?(conn.assigns[:current_user].id, follow_user_id)
  end

  def current_user?(conn, user) do
    conn.assigns[:current_user].id == user.id
  end

  def add_first_page_param(action) do
    "#{action}?select_page=1"
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