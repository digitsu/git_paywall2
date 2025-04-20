defmodule GitPaywall2.Repo.Migrations.CreateAccessRecords do
  use Ecto.Migration

  def change do
    create table(:access_records) do
      add :access_token, :string, null: false
      add :expires_at, :utc_datetime, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :repository_id, references(:repositories, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:access_records, [:user_id])
    create index(:access_records, [:repository_id])
    create index(:access_records, [:access_token])
    create index(:access_records, [:expires_at])
  end
end
