defmodule Brew do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    if_wlan = Application.get_env(:brew, :wlan0) || []

    children = [
      worker(Brew.TemperatureControl, []),
      worker(Nerves.InterimWiFi, ["wlan0", if_wlan], function: :setup)
    ]

    dispatch = :cowboy_router.compile [{:_,[{"/", Brew.Web, []}]}]
    :cowboy.start_http(__MODULE__, 10, [port: 80], [env: [dispatch: dispatch]])

    opts = [strategy: :one_for_one, name: Brew.Supervisor]
    Supervisor.start_link children, opts
  end

end
