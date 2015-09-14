defmodule SampleApp.LayoutView do
  use SampleApp.Web, :view

  def get_controller_name(conn), do: controller_module(conn)
  def get_action_name(conn), do: action_name(conn)
end
