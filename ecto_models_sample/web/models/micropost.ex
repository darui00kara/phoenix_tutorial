defmodule EctoModelsSample.Micropost do
  use EctoModelsSample.Web, :model

  schema "microposts" do
    field :content, :string
    belongs_to :user, EctoModelsSample.User, foreign_key: :user_id

    timestamps
  end

  @required_fields ~w(content user_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
