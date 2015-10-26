defmodule SampleApp.RelationshipTest do
  use SampleApp.ModelCase

  alias SampleApp.Relationship

  @valid_attrs %{followed_id: 42, follower_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Relationship.changeset(%Relationship{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Relationship.changeset(%Relationship{}, @invalid_attrs)
    refute changeset.valid?
  end
end
