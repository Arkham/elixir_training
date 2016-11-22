defmodule FrequencyPlus do

  ## Public API

  def start do
    pid = spawn(__MODULE__, :init, [])
    Process.register(pid, __MODULE__)
  end

  def allocate, do: call(:allocate)
  def deallocate(freq), do: call({:deallocate, freq})

  ## Callbacks

  def init do
    Process.flag(:trap_exit, true)
    frequencies = {get_frequencies(), []}
    loop(frequencies)
  end

  def loop(frequencies) do
    receive do
      {:request, pid, :allocate} ->
        {new_frequencies, reply} = allocate(frequencies, pid)
        reply(pid, reply)
        loop(new_frequencies)
      {:request, pid, {:deallocate, freq}} ->
        new_frequencies = deallocate(frequencies, freq)
        reply(pid, :ok)
        loop(new_frequencies)
      {:EXIT, pid, _reason} ->
        frequencies = exited(frequencies, pid)
        loop(frequencies)
      {:request, pid, :stop} ->
        reply(pid, :ok)
    end
  end

  ## Private

  defp call(command) do
    send(__MODULE__, {:request, self(), command})

    receive do
      {:reply, reply} -> reply
    end
  end

  def reply(pid, reply) do
    send pid, {:reply, reply}
  end

  defp get_frequencies do
    [10, 11, 12, 13, 14, 15]
  end

  defp allocate({[], allocated}, _pid) do
    {{[], allocated}, {:error, :no_frequencies}}
  end
  defp allocate({[freq|free], allocated}, pid) do
    Process.link(pid)
    {{free, [{freq, pid}|allocated]}, {:ok, freq}}
  end

  defp deallocate({free, allocated}, freq) do
    {freq, pid} = List.keyfind(allocated, freq, 0)
    Process.unlink(pid)
    allocated = List.keydelete(allocated, freq, 0)
    {[freq|free], allocated}
  end

  defp exited({free, allocated}, pid) do
    case List.keyfind(allocated, pid, 1) do
      {freq, _pid} ->
        allocated = List.keydelete(allocated, freq, 0)
        {[freq|free], allocated}
      nil ->
        {free, allocated}
    end
  end
end
