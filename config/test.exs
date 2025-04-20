import Config

# Configure your database
config :git_paywall2, GitPaywall2.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "git_paywall2_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test.
config :git_paywall2, GitPaywall2Web.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "test_key_very_secret_at_least_64_bytes_long_xxxxxxxxxxxxxxxxxxxxxxxx",
  server: false

# Configure BSV network to mocknet for tests
config :git_paywall2, :bsv,
  network: :mocknet

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
