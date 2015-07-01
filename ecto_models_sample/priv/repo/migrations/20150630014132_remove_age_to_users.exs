defmodule EctoModelsSample.Repo.Migrations.RemoveAgeToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :age
    end
  end
end
