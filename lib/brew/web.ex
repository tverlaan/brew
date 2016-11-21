defmodule Brew.Web do

  def init(_, req, state) do
    {:ok, req, state}
  end

  def handle(req, s) do

    {:ok, reply} = :cowboy_req.reply( 200, [ {"content-type", "text/html"} ], build_body(), req)

    {:ok, reply, s}
  end

  def terminate(_reason, _req, _s) do
    :ok
  end

  defp build_body() do
    temp = Brew.TemperatureControl.read :brew
    fridge = Brew.TemperatureControl.fridge? :brew
    bulb = Brew.TemperatureControl.bulb? :brew

    operating_mode = case {fridge, bulb} do
      {true, _} -> "Cooling is on!"
      {_, true} -> "Heating is on!"
      _ -> "Everything is fine..."
    end

    """
    <html>
    <head>
      <title>Beer brewing temperature</title>
    </head>
    <body>
      <h1>Current temperature #{inspect temp} C</h1>
      <p>#{operating_mode}</p>
    </body>
    </html>
    """
  end

end
