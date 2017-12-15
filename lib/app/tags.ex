defmodule App.Tags do
  use GenServer

  ## Client

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_top_tag(user_id) do
  	tag = GenServer.call(__MODULE__, {:get, user_id})
  	elem(tag, 0)
  end

  def update_user_tags(user_id, user_tags) do
    GenServer.cast(__MODULE__, {:set, user_id, user_tags})
  end

  ## Server

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({:set, user_id, user_tags}, state) do
    {:noreply, Map.update(state, user_id, Map.new(user_tags, &({&1, 0})), &(Enum.each(user_tags, fn x -> Map.update(&1, x, 0, fn y -> y + 1 end) end)))}
  end

  def handle_call({:get, user_id}, _from, state) do
    {:reply, (state[user_id] |> Map.to_list |> Enum.sort_by(&(elem(&1, 1)), &>=/2) |> Enum.at(0)), state}
  end
end