defmodule GitPaywall2.AccessControl.AccessRecord do
  use Ecto.Schema
  import Ecto.Changeset

  schema "access_records" do
    field :access_token, :string
    field :expires_at, :utc_datetime

    belongs_to :user, GitPaywall2.Accounts.User
    belongs_to :repository, GitPaywall2.Repositories.Repository

    timestamps()
  end

  def changeset(access_record, attrs) do
    access_record
    |> cast(attrs, [:access_token, :expires_at, :user_id, :repository_id])
    |> validate_required([:access_token, :expires_at, :user_id, :repository_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:repository_id)
  end
end
