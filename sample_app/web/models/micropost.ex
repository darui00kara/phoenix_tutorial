defmodule SampleApp.Micropost do
  use SampleApp.Web, :model

  schema "microposts" do
    field :content, :string
    
    belongs_to :user, SampleApp.User, foreign_key: :user_id

    timestamps
  end

  @required_fields ~w(content user_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:content, min: 1)
    |> validate_length(:content, max: 140)
  end

  def paginate(user_id, select_page) do
    SampleApp.Helpers.PaginationHelper.paginate(
      from(m in SampleApp.Micropost, where: m.user_id == ^user_id, order_by: [desc: m.inserted_at]),
      select_page)
  end

  def new(user_id) do
    %SampleApp.Micropost{}
    |> cast(%{content: "", user_id: user_id}, @required_fields, @optional_fields)
  end

  def paginate(user_id, select_page, following_ids) do
    SampleApp.Helpers.PaginationHelper.paginate(
      from(m in SampleApp.Micropost,
        where: m.user_id in ^following_ids or m.user_id == ^user_id,
          order_by: [desc: m.inserted_at]),
      select_page)
  end
end
