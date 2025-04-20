defmodule GitPaywall2Web.GitController do
  use GitPaywall2Web, :controller

  alias GitPaywall2.AccessControl
  alias GitPaywall2.Repositories

  def serve(conn, %{"repo_id" => repo_id, "token" => token}) do
    case AccessControl.validate_access_token(repo_id, token) do
      {:ok, _access_record} ->
        # In a real implementation, this would serve actual Git content
        # For now, just simulate a successful response
        conn
        |> put_resp_content_type("application/x-git-receive-pack-result")
        |> send_resp(200, "Git repository content would be served here")

      {:error, :invalid_token} ->
        conn
        |> put_status(401)
        |> json(%{error: "Invalid or expired access token"})
    end
  end

  def serve(conn, %{"repo_id" => repo_id}) do
    # No token provided, redirect to clone endpoint for authorization
    conn
    |> put_resp_header("Location", "/api/repos/#{repo_id}/clone")
    |> send_resp(302, "")
  end
end
