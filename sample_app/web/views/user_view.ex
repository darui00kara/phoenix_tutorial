defmodule SampleApp.UserView do
  use SampleApp.Web, :view
  alias SampleApp.User

  def get_gravatar_url(%User{email: email}) do
    SampleApp.Gravator.get_gravatar_url(email, 50)
  end

  def is_empty_list?(list) when is_list(list) do
    list == []
  end

  def following?(conn, follow_user_id) do
    SampleApp.Relationship.following?(conn.assigns[:current_user].id, follow_user_id)
  end
end