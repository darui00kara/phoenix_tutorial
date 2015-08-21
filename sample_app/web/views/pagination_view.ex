defmodule SampleApp.PaginationView do
  use SampleApp.Web, :view

  def get_previous_page_url(action, current_page) do
    get_page_url(action, current_page - 1)
  end

  def get_next_page_url(action, current_page) do
    get_page_url(action, current_page + 1)
  end

  def get_page_url(action, page_number) do
    "#{action}?select_page=#{page_number}"
  end
end