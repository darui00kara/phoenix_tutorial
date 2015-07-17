defmodule SampleApp.Repo.Migrations.RemoveRememberTokenToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :remember_token
    end
  end
end
