defmodule App.Cities do
  @url "https://iatacodes.org/api/v6/cities?api_key=279b4c81-fdcb-4aa2-8241-e83e2d2adafe"
  use GenServer

  ## Client

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_city_code(city_name) do
  	{:ok, code} = GenServer.call(__MODULE__, {:getcode, city_name})
  	code
  end

  def get_city_name(city_code) do
  	{:ok, name} = GenServer.call(__MODULE__, {:getname, city_code})
  	name
  end

  ## Server

  def init(:ok) do
    HTTPotion.start
    cities = HTTPotion.get(@url).body |> Poison.decode |> elem(1) |> Map.get("response")
    {:ok, cities}
  end

  def handle_call({:getcode, city_name}, _from, cities) do
    city = cities |> Enum.find(fn x -> String.downcase(x["name"]) == String.downcase(city_name) end)
    
    if is_nil(city) do
    	{:reply, {:ok, nil}, cities}
    else
    	{:reply, Map.fetch(city, "code"), cities}
    end
  end

  def handle_call({:getname, city_code}, _from, cities) do
    code = cities
    |> Enum.find(fn x -> String.downcase(x["code"]) == String.downcase(city_code) end)
    |> Map.fetch("name")

    {:reply, code, cities}
  end
end