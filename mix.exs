defmodule Refactory.MixProject do
  use Mix.Project

  @source_url "https://github.com/elixir-dx/refactory"

  def project do
    [
      app: :refactory,
      version: version(),
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      aliases: aliases(),
      deps: deps(),
      docs: docs()
    ]
  end

  defp package do
    [
      description: "Generate test data recursively with traits",
      files: ["lib", "mix.exs", "README*", "VERSION"],
      maintainers: ["Arno Dirlam"],
      licenses: ["MIT"],
      links: %{
        Changelog: "https://github.com/elixir-dx/refactory/blob/main/CHANGELOG.md",
        GitHub: @source_url
      }
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger] ++ test_apps(Mix.env())
    ]
  end

  defp test_apps(:test) do
    [:ecto_sql, :postgrex]
  end

  defp test_apps(_), do: []

  defp deps do
    [
      {:ecto, "~> 3.0"},

      # dev & test
      {:ecto_sql, "~> 3.0", only: [:dev, :test]},
      {:postgrex, "~> 0.14", only: :test, runtime: false},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  def docs do
    [
      main: "Refactory",
      source_url: @source_url,
      source_ref: "v#{version()}"
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.reset", "test"]
    ]
  end

  defp version do
    "VERSION"
    |> File.read!()
    |> String.trim()
  end
end
