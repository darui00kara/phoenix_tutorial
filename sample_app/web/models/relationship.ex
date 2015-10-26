defmodule SampleApp.Relationship do
  use SampleApp.Web, :model

  schema "relationships" do
    belongs_to :followed_user, SampleApp.User, foreign_key: :follower_id
    belongs_to :follower, SampleApp.User, foreign_key: :followed_id

    timestamps
  end

  @required_fields ~w(follower_id followed_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_presence(:follower_id)
    |> validate_presence(:followed_id)
  end

  def follow!(signed_id, follow_user_id) do
    changeset = SampleApp.Relationship.changeset(
      %SampleApp.Relationship{}, %{follower_id: signed_id, followed_id: follow_user_id})

    if changeset.valid? do
      SampleApp.Repo.insert!(changeset)
    end
  end

  def following?(signed_id, follow_user_id) do
    relationship = SampleApp.Repo.all(
      from(r in SampleApp.Relationship,
        where: r.follower_id == ^signed_id and r.followed_id == ^follow_user_id, limit: 1))

    !Enum.empty?(relationship)
  end

  def unfollow!(signed_id, follow_user_id) do
    [relationship] = SampleApp.Repo.all(
      from(r in SampleApp.Relationship,
        where: r.follower_id == ^signed_id and r.followed_id == ^follow_user_id, limit: 1))

    SampleApp.Repo.delete!(relationship)
  end
end
