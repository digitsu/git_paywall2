defmodule GitPaywall2Web.RepoJSON do
  @doc """
  Renders a list of repositories.
  """
  def index(%{repositories: repositories}) do
    %{repositories: for(repo <- repositories, do: data(repo))}
  end

  @doc """
  Renders a single repository.
  """
  def show(%{repo: repo}) do
    %{data: data(repo)}
  end

  defp data(repo) do
    %{
      id: repo.id,
      name: repo.name,
      description: repo.description,
      price: repo.price,
      owner_id: repo.owner_id
    }
  end
end
