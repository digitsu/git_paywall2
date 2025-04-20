defmodule GitPaywall2.Payments do
  @moduledoc """
  Handles payment verification using Bitcoin SV
  """

  import Ecto.Query
  alias GitPaywall2.Repo
  alias GitPaywall2.Payments.Payment
  alias GitPaywall2.BSV.Explorer
  alias GitPaywall2.BSV.Wallet

  def get_payment(id) do
    case Repo.get(Payment, id) do
      nil -> {:error, :not_found}
      payment -> {:ok, payment}
    end
  end

  def get_payment_by_txid(txid) do
    Repo.get_by(Payment, txid: txid)
  end

  def list_payments_by_user(user_id) do
    query = from p in Payment, where: p.user_id == ^user_id
    Repo.all(query)
  end

  def list_payments_by_repository(repo_id) do
    query = from p in Payment, where: p.repository_id == ^repo_id
    Repo.all(query)
  end

  def check_status(user_id, repo_id) do
    # First, check the database for confirmed payments
    query = from p in Payment,
            where: p.user_id == ^user_id and
                   p.repository_id == ^repo_id and
                   p.confirmed == true,
            select: sum(p.amount)

    db_amount = Repo.one(query) || 0

    if db_amount > 0 do
      {:ok, %{amount: db_amount, paid: true}}
    else
      # If nothing in the database, check the blockchain
      repo_payment_address = Wallet.get_payment_address(repo_id)

      with {:ok, transactions} <- Explorer.get_address_history(repo_payment_address),
           {:ok, user_transactions} <- filter_user_transactions(transactions, user_id),
           payment_amount = calculate_total_paid(user_transactions) do

        # Record payments found on chain but not in our database
        if payment_amount > 0 do
          record_blockchain_payments(user_id, repo_id, user_transactions)
        end

        {:ok, %{amount: payment_amount, paid: payment_amount > 0}}
      else
        error -> error
      end
    end
  end

  defp filter_user_transactions(transactions, user_id) do
    # In a real implementation, this would filter transactions based on user metadata
    # For simplicity, we'll just return all transactions for now
    {:ok, transactions}
  end

  defp calculate_total_paid(transactions) do
    Enum.reduce(transactions, 0, fn tx, acc ->
      acc + tx.amount
    end)
  end

  defp record_blockchain_payments(user_id, repo_id, transactions) do
    # Record payments from blockchain that aren't in our database
    for tx <- transactions do
      case get_payment_by_txid(tx.txid) do
        nil ->
          # New transaction, record it
          record_payment(user_id, repo_id, tx.txid, tx.amount,
                        tx.confirmations >= 1, tx.confirmations)
        _existing ->
          # Already recorded, skip
          :ok
      end
    end
  end

  def record_payment(user_id, repo_id, txid, amount, confirmed \\ false, confirmations \\ 0) do
    attrs = %{
      user_id: user_id,
      repository_id: repo_id,
      txid: txid,
      amount: amount,
      confirmed: confirmed,
      confirmations: confirmations
    }

    %Payment{}
    |> Payment.changeset(attrs)
    |> Repo.insert()
  end

  def update_payment_confirmation(payment, confirmations) do
    confirmed = confirmations >= 1

    payment
    |> Payment.changeset(%{confirmed: confirmed, confirmations: confirmations})
    |> Repo.update()
  end
end
