defmodule MutexPlus do
  @name :mutex_plus

  def start do
    pid = spawn(__MODULE__, :init, [])
    Process.register(pid, @name)
    :ok
  end

  def stop, do: call(:stop)
  def wait, do: call(:wait)
  def signal, do: call(:signal)

  def init do
    Process.flag(:trap_exit, true)
    free()
  end

  def free do
    receive do
      {:request, pid, :wait} ->
        reply(pid, :ok)
        Process.link(pid)
        busy(pid)

      {:request, pid, :stop} ->
        reply(pid, :ok)

      {:EXIT, _pid, _reason} ->
        free()
    end
  end

  def busy(owner) do
    receive do
      {:request, ^owner, :wait} ->
        reply(owner, {:error, :already_owned})
        busy(owner)

      {:request, ^owner, :signal} ->
        reply(owner, :ok)
        free()

      {:request, pid, :stop} ->
        reply(pid, :ok)

      {:EXIT, ^owner, reason} ->
        IO.puts "Owner #{inspect(owner)} crashed (#{inspect(reason)}), freeing mutex"
        free()
    end
  end

  defp call(message) do
    send(@name, {:request, self(), message})

    receive do
      {:reply, reply} -> reply
    end
  end

  defp reply(pid, reply) do
    send(pid, {:reply, reply})
  end
end
