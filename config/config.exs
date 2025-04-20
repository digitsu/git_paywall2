import Config

config :git_paywall2, GitPaywall2.Repo,
  database: "git_paywall2_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :git_paywall2, ecto_repos: [GitPaywall2.Repo]

config :git_paywall2, GitPaywall2Web.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: GitPaywall2Web.ErrorHTML, json: GitPaywall2Web.ErrorJSON],
    layout: false
  ],
  pubsub_server: GitPaywall2.PubSub,
  live_view: [signing_salt: "aS1SJmfT"]

config :git_paywall2, :bsv,
  network: :mainnet,
  explorer_url: "https://api.whatsonchain.com/v1/bsv/main"

# Configure esbuild
config :esbuild,
  version: "0.17.11",
  git_paywall2: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind
config :tailwind,
  version: "3.3.2",
  git_paywall2: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :phoenix, :json_library, Jason

# Optional configuration for config/config.exs
# This disables Swoosh completely

config :git_paywall2, GitPaywall2.Mailer, adapter: Swoosh.Adapters.Test

# Disable Swoosh
config :swoosh, :api_client, false

import_config "#{config_env()}.exs"
