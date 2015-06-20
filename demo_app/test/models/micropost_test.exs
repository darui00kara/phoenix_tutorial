defmodule DemoApp.MicropostTest do
  use DemoApp.ModelCase

  alias DemoApp.Micropost

  @valid_attrs %{content: "some content", user_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Micropost.changeset(%Micropost{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Micropost.changeset(%Micropost{}, @invalid_attrs)
    refute changeset.valid?
  end
end
