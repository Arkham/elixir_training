defmodule FrequencyGen do
  use GenServer

  @name :frequency_gen

  # Public API
  def start_link do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def allocate do
    GenServer.call(@name, :allocate)
  end

  def deallocate(freq) do
    GenServer.cast(@name, {:deallocate, freq})
  end

  def stop do
    GenServer.cast(@name, :stop)
  end

  # Callbacks
  def init([]) do
    Process.flag(:trap_exit, true)
    free = get_frequencies()
    allocated = []
    {:ok, {free, allocated}}
  end

  def handle_call(:allocate, {pid, _ref}, state) do
    {new_state, reply} = allocate(state, pid)
    {:reply, reply, new_state}
  end

  def handle_cast({:deallocate, freq}, state) do
    new_state = deallocate(state, freq)
    {:noreply, new_state}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  def handle_info({:EXIT, pid, reason}, state) do
    IO.puts "Process #{inspect(pid)} crashed because of reason #{inspect(reason)}"
    new_state = exited(state, pid)
    {:noreply, new_state}
  end

  def terminate(_reason, _state) do
    # clean up on termination
    :ok
  end

  # Private
  defp get_frequencies, do: [10,11,12,13,14,15]

  defp allocate({[] = _free, allocated}, _pid) do
    {{[], allocated}, {:error, :no_frequencies}}
  end
  defp allocate({[freq|free], allocated}, pid) do
    Process.link(pid)
    {{free, [{freq, pid}|allocated]}, {:ok, freq}}
  end

  defp deallocate({free, allocated} = state, freq) do
    case List.keyfind(allocated, freq, 0) do
      {freq, pid} ->
        Process.unlink(pid)
        allocated = List.keydelete(allocated, freq, 0)
        {[freq|free], allocated}
      nil ->
        state
    end
  end

  defp exited({free, allocated} = state, pid) do
    case List.keyfind(allocated, pid, 1) do
      {freq, _pid} ->
        allocated = List.keydelete(allocated, freq, 0)
        {[freq|free], allocated}
      nil ->
        state
    end
  end
end
