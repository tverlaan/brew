# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :nerves, :firmware,
  fwup_conf: "config/#{Mix.Project.config[:target]}/fwup.conf"

config :brew, :temperature,
  high: 21,
  low: 20

import_config "config.wifi.exs"
