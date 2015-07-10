defmodule EctoModelsSample.Repo.Migrations.DropMicropostsTable do
  use Ecto.Migration

  def change do
    drop table(:microposts)
  end
end
