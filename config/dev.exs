import Config

# Configure your database
config :git_paywall2, GitPaywall2.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "git_paywall2_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
config :git_paywall2, GitPaywall2Web.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "dev_key_very_secret_at_least_64_bytes_long_xxxxxxxxxxxxxxxxxxxxxxxx",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:git_paywall2, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:git_paywall2, ~w(--watch)]}
  ]

# Enable live reload
config :git_paywall2, GitPaywall2Web.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/git_paywall2_web/(controllers|live|components|templates)/.*(ex|heex)$"
    ]
  ]

# Configure BSV network to testnet for development
config :git_paywall2, :bsv,
  network: :testnet,
  explorer_url: "https://api.whatsonchain.com/v1/bsv/test"

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Enable dev routes for dashboard
config :git_paywall2, dev_routes: true

# Set a higher stacktrace during development
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
