defmodule GitPaywall2.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :amount, :float, null: false
      add :txid, :string, null: false
      add :confirmed, :boolean, default: false
      add :confirmations, :integer, default: 0
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :repository_id, references(:repositories, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:payments, [:user_id])
    create index(:payments, [:repository_id])
    create unique_index(:payments, [:txid])
  end
end
