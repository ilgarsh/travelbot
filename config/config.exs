use Mix.Config

config :app,
  bot_name: "travel_ai_bot"

config :nadia,
  token: ""

import_config "#{Mix.env}.exs"

config :app, App.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "",
  username: "",
  password: "",
  hostname: "",
  ssl: true

config :app, ecto_repos: [App.Repo]
