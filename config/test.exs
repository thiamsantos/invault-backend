use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :invault, InvaultWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :invault, Invault.Repo,
  username: "postgres",
  password: "postgres",
  database: "invault_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :invault, Invault.Mailer, adapter: Bamboo.TestAdapter
config :invault, Invault.CurrentTime, adapter: Invault.CurrentTime.Mock
