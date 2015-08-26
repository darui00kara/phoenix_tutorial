defmodule SampleApp.Helpers.PaginationHelper do
  
  @first_page "1"
  @page_size "2"

  defp is_nil_or_empty?(select_page) do
    is_nil(select_page) || select_page == ""
  end

  defp is_valid_value?(select_page) do
    Regex.match?(~r/^[0-9]+$/, select_page)
  end

  defp is_able_to_paginate?(select_page) do
    !is_nil_or_empty?(select_page) && is_valid_value?(select_page)
  end
  
  def paginate(query, select_page) do
    if is_able_to_paginate?(select_page) do
      query |> SampleApp.Repo.paginate(page: select_page, page_size: @page_size)
    else
      query |> SampleApp.Repo.paginate(page: @first_page, page_size: @page_size)
    end
  end
end