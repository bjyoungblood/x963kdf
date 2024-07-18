defmodule X963KDF.MixProject do
  use Mix.Project

  @version "0.1.1"
  @source_url "https://github.com/bjyoungblood/x963kdf"

  def project do
    [
      app: :x963kdf,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Pure Elixir implementation of ANSI X9.63 Key Derivation Function",
      preferred_cli_env: [docs: :docs, "hex.publish": :docs, dialyzer: :test],
      source_url: @source_url,
      dialyzer: dialyzer(),
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:crypto]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :docs, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp dialyzer() do
    ci_opts =
      if System.get_env("CI") do
        [plt_core_path: "_build/plts", plt_local_path: "_build/plts"]
      else
        []
      end

    [
      flags: [:unmatched_returns, :error_handling, :missing_return, :extra_return]
    ] ++ ci_opts
  end

  defp docs do
    [
      extras: ["README.md"],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
