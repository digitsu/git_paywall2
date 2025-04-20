defmodule GitPaywall2.Payments.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "payments" do
    field :amount, :float
    field :txid, :string
    field :confirmed, :boolean, default: false
    field :confirmations, :integer, default: 0

    belongs_to :user, GitPaywall2.Accounts.User
    belongs_to :repository, GitPaywall2.Repositories.Repository

    timestamps()
  end

  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:amount, :txid, :confirmed, :confirmations, :user_id, :repository_id])
    |> validate_required([:amount, :txid, :user_id, :repository_id])
    |> validate_number(:amount, greater_than: 0)
    |> unique_constraint(:txid)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:repository_id)
  end
end
