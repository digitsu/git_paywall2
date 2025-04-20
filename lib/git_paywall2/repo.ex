defmodule GitPaywall2.Repo do
  use Ecto.Repo,
    otp_app: :git_paywall2,
    adapter: Ecto.Adapters.Postgres
end
