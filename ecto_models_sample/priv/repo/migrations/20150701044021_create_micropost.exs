defmodule EctoModelsSample.Repo.Migrations.CreateMicropost do
  use Ecto.Migration

  def change do
    create table(:microposts) do
      add :content, :string

      timestamps
    end

  end
end
