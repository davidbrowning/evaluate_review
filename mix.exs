defmodule EvaluateReview.MixProject do
  use Mix.Project

  def project do
    [
      app: :evaluate_review,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "EvaluateReview",
      source_url: "https://github.com/davidbrowning/evaluate_review",
      docs: [
        main: "readme",
        extras: [
          "README.md"
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2"},
      {:floki, "~> 0.30.0"},
      {:ex_doc, "~> 0.18", only: :dev}
    ]
  end
end
