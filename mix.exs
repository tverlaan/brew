defmodule BrewEx.Mixfile do
  use Mix.Project

  @target System.get_env("NERVES_TARGET") || "rpi2"

  def project do
    [app: :brew_ex,
     version: "0.0.1",
     target: @target,
     elixir: "~> 1.2",
     archives: [nerves_bootstrap: "0.1.2"],
     deps_path: "deps/#{@target}",
     build_path: "_build/#{@target}",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps ++ system(@target)]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [
        :logger,
        :nerves,
        :elixir_ale,
        :onewire_therm,
        :nerves_network_interface
      ],
      mod: {BrewEx.Application, []}
    ]
  end

  defp deps do
    [
      {:nerves, "~> 0.3"},
      {:nerves_network_interface, "~> 0.3"},
      {:onewire_therm, github: "tverlaan/onewire_therm"},
      {:elixir_ale, "~> 0.5"}
    ]
  end

  def system(target) do
    [{:"nerves_system_#{target}", ">= 0.0.0"}]
  end

  def aliases do
    ["deps.precompile": ["nerves.precompile", "deps.precompile"],
     "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"]]
  end

end
