defmodule SampleApp.Repo.Migrations.CreateUser do
  use Ecto.Migration
  @disable_ddl_transaction true

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string

      timestamps
    end

    create index(:users, [:name], unique: true, concurrently: true)
    create index(:users, [:email], unique: true, concurrently: true)
  end
end
