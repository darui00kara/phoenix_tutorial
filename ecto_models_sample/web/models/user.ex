defmodule EctoModelsSample.User do
  use EctoModelsSample.Web, :model
  use Ecto.Model.Callbacks

  before_insert :set_password_digest

  schema "users" do
    field :name, :string
    field :email, :string
    field :password_digest, :string
    field :password, :string, virtual: true

    timestamps
  end

  @required_fields ~w(name email password)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:email, ~r/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
    |> validate_unique(:name, on: EctoModelsSample.Repo)
    |> validate_unique(:email, on: EctoModelsSample.Repo)
    |> validate_length(:name, min: 1)
    |> validate_length(:name, max: 50)
    |> validate_length(:password, min: 8)
    |> validate_length(:password, max: 100)
    |> validate_name_presence()
  end

  def set_password_digest(changeset) do
    password = Ecto.Changeset.get_field(changeset, :password)
    change(changeset, %{password_digest: password})
  end

  def validate_name_presence(changeset) do
    name = Ecto.Changeset.get_field(changeset, :name)
    cond do
      name == nil ->
        add_error changeset, :name, "Name is nil"
      name == "" ->
        add_error changeset, :name, "No Name"
      true ->
        changeset
    end
  end
end
