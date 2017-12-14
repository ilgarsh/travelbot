defmodule App.Dialog do
  use GenServer

  ## Client

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_user_progress(user_id) do
  	{:ok, progress} = user_id
  	|> get_user_state
  	|> Map.fetch(:dialog)

  	progress
  end

  def get_user_city(user_id) do
  	{:ok, city} = user_id
  	|> get_user_state
  	|> Map.fetch(:city)

  	city
  end

  def get_user_month(user_id) do
    {:ok, month} = user_id
    |> get_user_state
    |> Map.fetch(:month)

    month
  end

  def get_user_price(user_id) do
    {:ok, price} = user_id
    |> get_user_state
    |> Map.fetch(:price)

    price
  end

  def get_user_destination(user_id) do
    {:ok, destination} = user_id
    |> get_user_state
    |> Map.fetch(:destination)

    destination
  end

  def get_user_state(user_id) do
    case GenServer.call(__MODULE__, user_id) do
    	{:ok, state} -> state
    	_ -> "No state for this user"
    end
  end

  def get_user_tags(user_id) do
    {:ok, tags} = user_id
    |> get_user_state
    |> Map.fetch(:tags)

    tags
  end

  def add_user(user_id) do
  	GenServer.cast(__MODULE__, {:add, user_id})
  end

  def set_dialog_progress(user_id, dialog_progress) do
    GenServer.cast(__MODULE__, {:dialogup, user_id, dialog_progress})
  end

  def set_user_city(user_id, city_code) do
  	GenServer.cast(__MODULE__, {:setcity, user_id, city_code})
  end

  def set_user_month(user_id, month) do
  	GenServer.cast(__MODULE__, {:setmonth, user_id, month})
  end

  def set_user_price(user_id, price) do
  	GenServer.cast(__MODULE__, {:setprice, user_id, price})
  end

  def set_user_destination(user_id, desination) do
    GenServer.cast(__MODULE__, {:setdestination, user_id, desination})
  end

  def set_user_tags(user_id, tags) do
    GenServer.cast(__MODULE__, {:settags, user_id, tags})
  end

  ## Server

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call(user_id, _from, state) do
    {:reply, Map.fetch(state, user_id), state}
  end

  def handle_cast({:dialogup, user_id, dialog_progress}, state) do
    {:noreply, Map.update(state, user_id, 0, &(Map.update(&1, :dialog, 0, fn _x -> dialog_progress end)))}
  end

  def handle_cast({:add, user_id}, state) do
  	{:noreply, Map.put_new(state, user_id, %{:dialog => :start, :city => "", :price => "", :month => "", :destination => "", :tags => []})}
  end

  def handle_cast({:setcity, user_id, city_code}, state) do
  	{:noreply, Map.update(state, user_id, 0, &(Map.update(&1, :city, 0, fn _x -> city_code end)))}
  end

  def handle_cast({:setmonth, user_id, month}, state) do
  	{:noreply, Map.update(state, user_id, 0, &(Map.update(&1, :month, 0, fn _x -> month end)))}
  end

  def handle_cast({:setprice, user_id, price}, state) do
  	{:noreply, Map.update(state, user_id, 0, &(Map.update(&1, :price, 0, fn _x -> price end)))}
  end

  def handle_cast({:setdestination, user_id, desination}, state) do
    {:noreply, Map.update(state, user_id, 0, &(Map.update(&1, :desination, 0, fn _x -> desination end)))}
  end

  def handle_cast({:settags, user_id, tags}, state) do
    {:noreply, Map.update(state, user_id, 0, &(Map.update(&1, :tags, 0, fn _x -> tags end)))}
  end

  ## Helpers

  def result_proposals(user_id) do
    proposals = Aviasales.get_proposals(get_user_city(user_id), get_user_destination(user_id), get_user_month(user_id), get_user_price(user_id))
    tag_names = Enum.join(get_user_tags(user_id), ", ")
    IO.inspect tag_names
    if tag_names != "" do
      query = "
      SELECT iata
      FROM cities
      WHERE tag_id IN (SELECT id FROM tags WHERE name IN ('" <> tag_names <> "'))"
      {:ok, result} = Ecto.Adapters.SQL.query(App.Repo, query)
      iatas = result.rows |> Enum.map(fn x -> List.first(x) end)
      cities = Enum.filter(proposals, fn x -> Enum.member?(iatas, x.destination) end)
    else
      proposals
    end
  end

  #SELECT iata FROM cities WHERE tag_id IN (SELECT id FROM tags WHERE name IN ("beach"))
end