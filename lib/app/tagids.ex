defmodule App.Tagids do
  use GenServer

  ## Client

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_id(tag_name) do
  	GenServer.call(__MODULE__, {:get, tag_name})
  end

  def set_ids() do
    GenServer.cast(__MODULE__, :set)
  end


  ## Server

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:get, tag_name}, _from, state) do
    {:reply, state[tag_name], state}
  end

  def handle_cast(:set, state) do
    {:ok, result} = Ecto.Adapters.SQL.query(App.Repo, "select name, id from tags")
    Map.new(result.rows, fn x -> {Enum.at(x, 0), Enum.at(x, 1)} end)
    {:noreply, Map.new(result.rows, fn x -> {Enum.at(x, 0), Enum.at(x, 1)} end)}
  end
end