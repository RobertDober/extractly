defmodule Extractly.MixProject do
  use Mix.Project

  @version "0.1.0"

  @description """
  Extractly `mix xtra` task to render `EEx` templates with easy access to hexdocs.

  The Extractly module gives easy access to Elixir metainformation of the application using the extractly package, notably, module and function documentation.
  """


  def project do
    [
      app: :extractly,
      version: @version,
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: @description,
      package: package(),
      # aliases: [docs: &docs/1, readme: &readme/1],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:excoveralls, "~> 0.10.3", only: :test},
      {:dialyxir, "~> 1.0.0-rc", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.19.2", only: [:dev, :test], runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      files: [
        "lib",
        "mix.exs",
        "README.md"
      ],
      maintainers: [
        "Robert Dober <robert.dober@gmail.com>"
      ],
      licenses: [
        "Apache 2 (see the file LICENSE for details)"
      ],
      links: %{
        "GitHub" => "https://github.com/robertdober/extractly"
      }
    ]
  end
end
