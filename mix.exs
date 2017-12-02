defmodule BitfinexApi.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bitfinex_api,
      version: "0.1.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "bitfinex_api",
      source_url: "https://github.com/around25/bitfinex_api"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:httpoison, :websockex, :poison],
      env: [api_endpoint: "https://api.bitfinex.com", ws_endpoint: "wss://api.bitfinex.com/ws"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gen_stage, "~> 0.12.2"},
      {:poison, "~> 3.1"},
      {:decimal, "~> 1.4"},
      {:httpoison, "~> 0.13"},
      {:websockex, "~> 0.4.0"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    "Elixir library for Bitfinex (bitfinex.com) exchange API."
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Cosmin Harangus"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/around25/bitfinex_api"}
    ]
  end
end
