defmodule Brew.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do

    if_wlan = Application.get_env(:brew, :wlan0) || []

    children = [
      worker(Brew, []),
      worker(Nerves.InterimWiFi, ["wlan0", if_wlan], function: :setup)
    ]

    supervise(children, strategy: :one_for_one)
  end

end
