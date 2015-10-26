defmodule SampleApp.Repo.Migrations.CreateMicropost do
  use Ecto.Migration
  @disable_ddl_transaction true

  def change do
    create table(:microposts) do
      add :content, :string
      add :user_id, :integer

      timestamps
    end

    create index(:microposts, [:user_id, :inserted_at], concurrently: true)
  end
end
