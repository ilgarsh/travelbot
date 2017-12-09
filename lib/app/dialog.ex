defmodule App.Dialog do
  use GenServer

  ## Client

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_user_state(user) do
    GenServer.call(__MODULE__, user)
  end

  def set_user_state({user, user_state}) do
    GenServer.cast(__MODULE__, {user, user_state})
  end

  ## Server

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call(user, _from, state) do
    {:reply, Map.fetch(state, user), state}
  end

  def handle_cast({user, user_state}, state) do
    {:noreply, Map.update(state, user, :start, fn _x -> user_state end)}
  end
end