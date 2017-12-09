defmodule App.Cities do
  @url "https://iatacodes.org/api/v6/cities?api_key=279b4c81-fdcb-4aa2-8241-e83e2d2adafe"
  use GenServer

  ## Client

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_city_code(city) do
  	GenServer.call(__MODULE__, city)
  end

  ## Server

  def init(:ok) do
    HTTPotion.start
    cities = HTTPotion.get(@url).body |> Poison.decode |> elem(1) |> Map.get("response")
    {:ok, cities}
  end

  def handle_call(city, _from, cities) do
    code = cities
    |> Enum.find(%{"code" => "No such city"}, fn x -> String.downcase(x["name"]) == String.downcase(city) end)
    |> Map.get("code")

    {:reply, code, cities}
  end
end