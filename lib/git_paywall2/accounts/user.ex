defmodule GitPaywall2.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string
    field :bsv_address, :string

    has_many :repositories, GitPaywall2.Repositories.Repository, foreign_key: :owner_id
    has_many :payments, GitPaywall2.Payments.Payment
    has_many :access_records, GitPaywall2.AccessControl.AccessRecord

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :bsv_address])
    |> validate_required([:username, :email])
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end
end
