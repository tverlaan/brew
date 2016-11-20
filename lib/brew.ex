defmodule Brew do
  use GenServer
  require Logger

  @type t :: %__MODULE__{
    temperature: float,
    low: integer,
    high: integer,
    fridge: pid,
    bulb: pid
  }
  defstruct [:temperature, :low, :high, :fridge, :bulb]

  @onewire 'w1'
  @address '28-0315a603beff'

  ## API

  @doc """
  Read temperature from a specific sensor.
  """
  @spec read_temperature(pid) :: float
  def read_temperature(server) do
    GenServer.call(server, :read_temperature)
  end

  @doc """
  Return state of fridge
  """
  @spec fridge?(pid) :: boolean
  def fridge?(server) do
    GenServer.call(server, :fridge)
  end

  @doc """
  Return state of the bulb (heating)
  """
  @spec bulb?(pid) :: boolean
  def bulb?(server) do
    GenServer.call(server, :bulb)
  end

  ## GenServer callbacks

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, [], name: :brew)
  end

  @doc false
  def init([]) do

    temperature = Application.get_env(:brew, :temperature)

    {:ok, _, _} = :onewire_therm_manager.subscribe(@onewire, @address)

    {:ok, fridge} = Gpio.start_link(17, :output)
    {:ok, bulb} = Gpio.start_link(18, :output)

    {:ok, %__MODULE__{bulb: bulb, fridge: fridge, low: temperature[:low], high: temperature[:high]}}
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
  def handle_info({:therm, {@onewire, @address}, temp, _time}, system) do
    temp = Float.round(temp, 1)
    Logger.debug "Temp: #{inspect temp}"

    control(temp, system)

    {:noreply, %__MODULE__{system | temperature: temp }}
  end

  defp control(temp, %__MODULE__{high: h} = system) when temp > h do
    system.bulb |> off
    system.fridge |> on
  end

  defp control(temp, %__MODULE__{low: l} = system) when temp < l do
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
