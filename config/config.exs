use Mix.Config

config :app,
  bot_name: "travel_ai_bot"

config :nadia,
  token: ""

import_config "#{Mix.env}.exs"
