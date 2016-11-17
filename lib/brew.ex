defmodule Brew do
  use GenServer
  require Logger

  defstruct [:temperature, :min, :max, :fridge, :bulb]

  @onewire 'w1'
  @address '28-0315a603beff'

  @high 21
  @low 20

  @doc """
  Start the worker
  """
  def start_link do
    GenServer.start_link(__MODULE__, [], name: :brew)
  end

  @doc """
  Read temperature from a specific sensor.
  """
  def read_temperature(server) do
    GenServer.call(server, :read_temperature)
  end

  def fridge?(server) do
    GenServer.call(server, :fridge)
  end

  def bulb?(server) do
    GenServer.call(server, :bulb)
  end

  ## GenServer callbacks

  @doc false
  def init([]) do
    {:ok, _, _} = :onewire_therm_manager.subscribe(@onewire, @address)

    {:ok, fridge} = Gpio.start_link(17, :output)
    {:ok, bulb} = Gpio.start_link(18, :output)

    {:ok, %__MODULE__{bulb: bulb, fridge: fridge}}
  end

  @doc false
  def handle_call(:read_temperature, _f, system) do
    {:reply, system.temperature, system}
  end

  @doc false
  def handle_call(:fridge, _f, system) do
    system.fridge
    |> Gpio.read
    |> Kernel.>(0)
    |> wrap_reply(system)
  end

  @doc false
  def handle_call(:bulb, _f, system) do
    system.bulb
    |> Gpio.read
    |> Kernel.>(0)
    |> wrap_reply(system)
  end

  @doc false
  def handle_info({:therm,{@onewire, @address},temp,_time}, system) do
    Logger.debug "Temp: #{inspect temp}"

    control(temp, system)

    {:noreply, %__MODULE__{system | temperature: temp }}
  end

  defp control(temp, system) when temp > @high do
    system.bulb |> off
    system.fridge |> on
  end

  defp control(temp, system) when temp < @low do
    system.bulb |> on
    system.fridge |> off
  end

  defp control(_, system) do
    system.bulb |> off
    system.fridge |> off
  end

  defp on(pid) do
    pid
    |> Gpio.read
    |> case do
        0 -> Gpio.write(pid, 1)
        _ -> :ok
      end
  end

  defp off(pid) do
    pid
    |> Gpio.read
    |> case do
        1 -> Gpio.write(pid, 0)
        _ -> :ok
      end
  end

  defp wrap_reply(val, system), do: {:reply, val, system}

end
