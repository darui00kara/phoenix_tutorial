defmodule SampleApp.Helpers.ValidateHelper do
  def validate_presence(changeset, field_name) do
    field_data = Ecto.Changeset.get_field(changeset, field_name)

    cond do
      field_data == nil ->
        Ecto.Changeset.add_error changeset, field_name, "#{field_name} is nil"
      field_data == "" ->
        Ecto.Changeset.add_error changeset, field_name, "No #{field_name}"
      true ->
        changeset
    end
  end
end