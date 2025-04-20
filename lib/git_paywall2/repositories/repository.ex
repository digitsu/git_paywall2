defmodule GitPaywall2.Repositories.Repository do
  use Ecto.Schema
  import Ecto.Changeset

  schema "repositories" do
    field :name, :string
    field :description, :string
    field :price, :float, default: 0.0

    belongs_to :owner, GitPaywall2.Accounts.User
    has_many :payments, GitPaywall2.Payments.Payment
    has_many :access_records, GitPaywall2.AccessControl.AccessRecord

    timestamps()
  end

  def changeset(repository, attrs) do
    repository
    |> cast(attrs, [:name, :description, :price, :owner_id])
    |> validate_required([:name, :owner_id])
    |> validate_number(:price, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:owner_id)
  end
end
