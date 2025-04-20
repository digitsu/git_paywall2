defmodule GitPaywall2.Repositories do
  @moduledoc """
  Handles repository management and pricing
  """

  import Ecto.Query
  alias GitPaywall2.Repo
  alias GitPaywall2.Repositories.Repository

  def get(repo_id) do
    case Repo.get(Repository, repo_id) do
      nil -> {:error, :not_found}
      repo -> {:ok, repo}
    end
  end

  def get_by_name(name) do
    Repo.get_by(Repository, name: name)
  end

  def list_repositories do
    Repo.all(Repository)
  end

  def list_repositories_by_owner(owner_id) do
    query = from r in Repository, where: r.owner_id == ^owner_id
    Repo.all(query)
  end

  def create_repository(attrs) do
    %Repository{}
    |> Repository.changeset(attrs)
    |> Repo.insert()
  end

  def update_repository(repo, attrs) do
    repo
    |> Repository.changeset(attrs)
    |> Repo.update()
  end

  def set_price(repo_id, price, owner_id) do
    with {:ok, repo} <- get(repo_id),
         :ok <- validate_owner(repo, owner_id) do

      update_repository(repo, %{price: price})
    else
      error -> error
    end
  end

  defp validate_owner(repo, owner_id) do
    if repo.owner_id == owner_id do
      :ok
    else
      {:error, :unauthorized}
    end
  end

  def delete_repository(repo_id, owner_id) do
    with {:ok, repo} <- get(repo_id),
         :ok <- validate_owner(repo, owner_id) do

      Repo.delete(repo)
    end
  end
end
