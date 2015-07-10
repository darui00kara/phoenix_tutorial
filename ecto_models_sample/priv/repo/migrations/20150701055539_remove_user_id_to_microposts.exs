defmodule EctoModelsSample.Repo.Migrations.RemoveUserIdToMicroposts do
  use Ecto.Migration

  def change do
    alter table(:microposts) do
      remove :user_id
    end
  end
end
