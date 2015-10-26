defmodule SampleApp.Repo.Migrations.AddPasswordToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password, :string
      add :password_digest, :string
    end
  end
end
