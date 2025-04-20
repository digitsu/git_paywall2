defmodule GitPaywall2.Accounts do
  @moduledoc """
  Handles user accounts management
  """

  import Ecto.Query
  alias GitPaywall2.Repo
  alias GitPaywall2.Accounts.User

  def get_user(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def get_user_by_username(username) do
    Repo.get_by(User, username: username)
  end

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def list_users do
    Repo.all(User)
  end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(id) do
    with {:ok, user} <- get_user(id) do
      Repo.delete(user)
    end
  end
end
