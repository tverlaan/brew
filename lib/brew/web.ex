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
    """
    <html>
    <head>
      <title>Beer brewing temperature</title>
    </head>
    <body>
      <h1>Current temp</h1>
      <p>#{inspect temp} C</p>
    </body>
    </html>
    """
  end

end
