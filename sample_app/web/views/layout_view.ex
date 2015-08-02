defmodule SampleApp.LayoutView do
  use SampleApp.Web, :view

  def current_user(conn) do
    conn.assigns[:current_user]
  end

  def add_first_page_param(action) do
    "#{action}?select_page=1"
  end
end