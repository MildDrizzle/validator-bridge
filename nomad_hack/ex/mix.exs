defmodule Lab.MixProject do
  use Mix.Project

  def project do
    [
      app: :lab,
      version: "0.1.0",
      elixir: "~> 1.13.1",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ssl],
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:erlport, github: "heyoka/erlport", branch: "master"},
      {:comsat, github: "vans163/comsat", branch: "master"},
      {:exjsx, "~> 4.0.0"},
      {:axon, "~> 0.1.0-dev", github: "elixir-nx/axon", branch: "main"},
      {:exla, "~> 0.1.0-dev", github: "elixir-nx/nx", sparse: "exla", override: true},
      {:nx, "~> 0.1.0-dev", github: "elixir-nx/nx", sparse: "nx", override: true},
    ]
  end
end

