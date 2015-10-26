defmodule SampleApp.User do
  use SampleApp.Web, :model
  use Ecto.Model.Callbacks

  before_insert :set_password_digest
  before_update :set_password_digest

  schema "users" do
    field :name, :string
    field :email, :string
    field :password_digest, :string
    field :password, :string, virtual: true

    has_many :microposts, SampleApp.Micropost

    has_many :followed_users, SampleApp.Relationship, foreign_key: :follower_id
    has_many :relationships, through: [:followed_users, :followed_user]

    has_many :followers, SampleApp.Relationship, foreign_key: :followed_id
    has_many :reverse_relationships, through: [:followers, :follower]

    timestamps
  end

  @required_fields ~w(name email password)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_presence(:name)
    |> validate_presence(:email)
    |> validate_format(:email, ~r/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
    |> unique_constraint(:name)
    |> unique_constraint(:email)
    |> validate_length(:name, min: 1)
    |> validate_length(:name, max: 50)
    |> validate_presence(:password)
    |> validate_length(:password, min: 8)
    |> validate_length(:password, max: 100)
  end

  def set_password_digest(changeset) do
    password = Ecto.Changeset.get_field(changeset, :password)
    change(changeset, %{password_digest: SampleApp.Encryption.encrypt(password)})
  end

  def new do
    %SampleApp.User{} |> cast(:empty, @required_fields, @optional_fields)
  end

  def find_user_from_email(email) do
    SampleApp.Repo.get_by(SampleApp.User, email: email)
  end

  def paginate(select_page) do
    SampleApp.Helpers.PaginationHelper.paginate(
      from(u in SampleApp.User, order_by: [asc: :name]),
      select_page)
  end

  def show_follow_paginate(select_page, ids_list) do
    SampleApp.Helpers.PaginationHelper.paginate(
      from(u in SampleApp.User, where: u.id in ^ids_list, order_by: [asc: :name]),
      select_page)
  end
end
