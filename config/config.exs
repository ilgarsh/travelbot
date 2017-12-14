use Mix.Config

config :app,
  bot_name: "travel_ai_bot"

config :nadia,
  token: "483825746:AAFn-P2lmYFMKi9Wv2Hz9UXMJK-UlSeXyVY"

import_config "#{Mix.env}.exs"

config :app, App.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "dojalo4vkj57s",
  username: "mmtcsmfzqxdbjc",
  password: "ca5cd9f8fa420bf946c4e5de066e26ade0c4f2eb9ff97efe4a0632d6772f26da",
  hostname: "ec2-54-235-193-84.compute-1.amazonaws.com",
  ssl: true

config :app, ecto_repos: [App.Repo]
