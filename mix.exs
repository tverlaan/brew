defmodule Brew.Mixfile do
  use Mix.Project

  @target System.get_env("NERVES_TARGET") || "rpi2"

  def project do
    [app: :brew,
     version: "0.0.1",
     target: @target,
     elixir: "~> 1.2",
     archives: [nerves_bootstrap: "0.1.4"],
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
        :nerves_interim_wifi,
        :nerves_firmware_http
      ],
      mod: {Brew, []}
    ]
  end

  defp deps do
    [
      {:nerves, "~> 0.3"},
      {:nerves_interim_wifi, "~> 0.1"},
      {:onewire_therm, github: "mokele/onewire_therm"},
      {:elixir_ale, "~> 0.5"},
      {:nerves_firmware_http, github: "nerves-project/nerves_firmware_http"},
      {:cowboy, "~> 1.0"}
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
