# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :invault,
  ecto_repos: [Invault.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :invault, InvaultWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "W6MrFvbnB2f+EXoCFyTiKyPXGfK6fzY7FjeWrZkaZBrf2tv8rX5kI/Qmej9YVlZi",
  render_errors: [view: InvaultWeb.ErrorView, accepts: ~w(json)]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id, :request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
