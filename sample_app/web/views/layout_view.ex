defmodule SampleApp.LayoutView do
  use SampleApp.Web, :view

  def current_user(conn) do
    conn.assigns[:current_user]
  end
end