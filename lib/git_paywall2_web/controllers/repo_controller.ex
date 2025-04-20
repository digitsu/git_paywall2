defmodule GitPaywall2Web.RepoController do
  use GitPaywall2Web, :controller

  alias GitPaywall2.Repositories
  alias GitPaywall2.AccessControl

  def get(conn, %{"repo_id" => repo_id}) do
    with {:ok, repo} <- Repositories.get(repo_id) do
      conn
      |> put_status(:ok)
      |> render(:show, repo: repo)
    else
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Repository not found"})

      error ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Error fetching repository"})
    end
  end

  def clone(conn, %{"repo_id" => repo_id}) do
    user_id = get_user_id(conn)

    case AccessControl.verify_access(repo_id, user_id) do
      {:ok, access_token} ->
        # Redirect to Git endpoint with access token
        conn
        |> put_resp_header("Location", "/git/#{repo_id}?token=#{access_token}")
        |> send_resp(302, "")

      {:error, :payment_required, payment_info} ->
        # Return HTTP 402 with payment details
        conn
        |> put_status(402)
        |> put_resp_header("X-Payment-Address", payment_info.address)
        |> put_resp_header("X-Payment-Amount", to_string(payment_info.amount))
        |> json(%{
          message: "Payment required to access this repository",
          payment_address: payment_info.address,
          amount: payment_info.amount,
          currency: "BSV"
        })

      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> json(%{error: "Repository not found"})

      {:error, _reason} ->
        conn
        |> put_status(403)
        |> json(%{error: "Access denied"})
    end
  end

  def set_price(conn, %{"repo_id" => repo_id, "price" => price}) do
    user_id = get_user_id(conn)

    case Repositories.set_price(repo_id, price, user_id) do
      {:ok, repo} ->
        json(conn, %{
          message: "Repository price updated successfully",
          repository: %{
            id: repo.id,
            name: repo.name,
            price: repo.price
          }
        })

      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> json(%{error: "Repository not found"})

      {:error, :unauthorized} ->
        conn
        |> put_status(403)
        |> json(%{error: "You are not authorized to modify this repository"})

      {:error, _changeset} ->
        conn
        |> put_status(400)
        |> json(%{error: "Invalid price value"})
    end
  end

  defp get_user_id(conn) do
    # Extract user ID from authentication token
    # This is just a placeholder - in a real app you'd use proper auth
    conn.assigns[:user_id] || "anonymous"
  end
end
