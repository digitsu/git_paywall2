defmodule GitPaywall2.Repo.Migrations.CreateRepositories do
  use Ecto.Migration

  def change do
    create table(:repositories) do
      add :name, :string, null: false
      add :description, :text
      add :price, :float, default: 0.0
      add :owner_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:repositories, [:owner_id])
    create unique_index(:repositories, [:name])
  end
end
