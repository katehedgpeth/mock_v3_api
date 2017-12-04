# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :mock_v3_api, MockV3ApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ENPwk/iN+Q000bpZ3tOwzrTf+ih8WR7CYUnN5RoEQJMycfUy/Ku129zqNlbKfT8q",
  render_errors: [view: MockV3ApiWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: MockV3Api.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
