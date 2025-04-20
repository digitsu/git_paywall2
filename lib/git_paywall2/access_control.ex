defmodule GitPaywall2.AccessControl do
  @moduledoc """
  Handles repository access control based on payment verification
  """

  import Ecto.Query
  alias GitPaywall2.Repo
  alias GitPaywall2.AccessControl.AccessRecord
  alias GitPaywall2.Repositories
  alias GitPaywall2.Payments
  alias GitPaywall2.BSV.Wallet

  @token_expiry_hours 24

  def verify_access(repo_id, user_id) do
    # First check for valid access tokens
    case get_valid_access_token(repo_id, user_id) do
      {:ok, token} ->
        # Valid token found
        {:ok, token}

      nil ->
        # No valid token, check payment status
        with {:ok, repo} <- Repositories.get(repo_id),
             {:ok, payment_status} <- Payments.check_status(user_id, repo_id),
             :ok <- validate_payment(payment_status, repo.price) do

          # Create new access token
          {:ok, access_record} = create_access_token(user_id, repo_id)
          {:ok, access_record.access_token}
        else
          {:error, :payment_required} ->
            # Need to get repo price before generating payment info
            with {:ok, repo} <- Repositories.get(repo_id) do
              payment_address = Wallet.generate_payment_address(repo_id)
              {:error, :payment_required, %{address: payment_address, amount: repo.price}}
            end

          error -> error
        end
    end
  end

  defp get_valid_access_token(repo_id, user_id) do
    now = DateTime.utc_now()

    query = from ar in AccessRecord,
            where: ar.repository_id == ^repo_id and
                   ar.user_id == ^user_id and
                   ar.expires_at > ^now,
            order_by: [desc: ar.expires_at],
            limit: 1

    case Repo.one(query) do
      nil -> nil
      access_record -> {:ok, access_record.access_token}
    end
  end

  defp validate_payment(payment_status, required_amount) do
    if payment_status.amount >= required_amount do
      :ok
    else
      {:error, :payment_required}
    end
  end

  defp create_access_token(user_id, repo_id) do
    token = :crypto.strong_rand_bytes(32) |> Base.encode16(case: :lower)
    expires_at = DateTime.utc_now() |> DateTime.add(@token_expiry_hours * 60 * 60)

    attrs = %{
      user_id: user_id,
      repository_id: repo_id,
      access_token: token,
      expires_at: expires_at
    }

    %AccessRecord{}
    |> AccessRecord.changeset(attrs)
    |> Repo.insert()
  end

  def validate_access_token(repo_id, token) do
    now = DateTime.utc_now()

    query = from ar in AccessRecord,
            where: ar.repository_id == ^repo_id and
                   ar.access_token == ^token and
                   ar.expires_at > ^now

    case Repo.one(query) do
      nil -> {:error, :invalid_token}
      access_record -> {:ok, access_record}
    end
  end

  def revoke_access(repo_id, user_id) do
    query = from ar in AccessRecord,
            where: ar.repository_id == ^repo_id and
                   ar.user_id == ^user_id

    {count, _} = Repo.delete_all(query)

    {:ok, count}
  end
end
