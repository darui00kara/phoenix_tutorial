defmodule SampleApp.LayoutView do
  use SampleApp.Web, :view

  def current_user(conn) do
    conn.assigns[:current_user]
  end

  def user_index_first_page(conn) do
    "#{user_path(conn, :index)}?select_page=1"
  end
end