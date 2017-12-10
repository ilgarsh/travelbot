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

  def get_user_state(user_id) do
    case GenServer.call(__MODULE__, user_id) do
    	{:ok, state} -> state
    	_ -> "No state for this user"
    end
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
  	{:noreply, Map.put_new(state, user_id, %{:dialog => :start, :city => "", :price => 0, :month => "", :tags => []})}
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
end