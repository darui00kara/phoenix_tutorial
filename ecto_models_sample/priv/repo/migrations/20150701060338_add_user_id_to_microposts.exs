defmodule EctoModelsSample.Repo.Migrations.AddUserIdToMicroposts do
  use Ecto.Migration

  def change do
    alter table(:microposts) do
      add :user_id, :integer
    end
  end
end
