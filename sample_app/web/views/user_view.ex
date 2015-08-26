defmodule SampleApp.UserView do
  use SampleApp.Web, :view

  def is_empty_list?(list) when is_list(list) do
    list == []
  end

  def following?(conn, follow_user_id) do
    SampleApp.Relationship.following?(conn.assigns[:current_user].id, follow_user_id)
  end
end