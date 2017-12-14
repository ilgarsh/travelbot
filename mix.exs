defmodule App.Mixfile do
  use Mix.Project

  def project do
    [app: :app,
     version: "0.1.0",
     elixir: "~> 1.5",
     default_task: "server",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     aliases: aliases()]
  end

  def application do
    [#applications: [:logger, :nadia],
     mod: {App, []}]
  end

  defp deps do
    [
      {:nadia, "~> 0.4.1"},
      {:distillery, "~> 1.5", runtime: false},
      {:httpotion, "~> 3.0.2"},
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.1"},
      {:postgrex, ">= 0.0.0"},
      {:ecto, "~> 2.1"}
    ]
  end

  defp aliases do
    [server: "run --no-halt"]
  end
end
