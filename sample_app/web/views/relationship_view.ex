defmodule SampleApp.RelationshipView do
  use SampleApp.Web, :view

  def following?(conn, follow_user_id) do
    SampleApp.Relationship.following?(conn.assigns[:current_user].id, follow_user_id)
  end
end