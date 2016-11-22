defmodule Sup do
  @max_restarts 5

  ## Public API

  def start(name) do
    pid = spawn(__MODULE__, :init, [])
    Process.register(pid, name)
    {:ok, pid}
  end

  def start_child(name, mod, func, args) do
    call(name, {:start_child, {mod, func, args}})
  end

  def status(name) do
    call(name, :status)
  end

  def stop(name) do
    send(name, :stop)
    :ok
  end

  ## Callbacks

  def init do
    Process.flag(:trap_exit, true)
    loop([])
  end

  def loop(children) do
    receive do
      {:request, pid, {:start_child, spec}} ->
        {:ok, child_pid} = start_child(spec)
        reply(pid, {:ok, child_pid})
        loop([{child_pid, spec, 0}|children])

      {:request, pid, :status} ->
        reply(pid, children)
        loop(children)

      :stop ->
        kill_all(children)
        :ok

      {:EXIT, pid, :normal} ->
        new_children = List.keydelete(children, pid, 0)
        loop(new_children)

      {:EXIT, pid, reason} ->
        IO.puts "Child #{inspect(pid)} crashed with reason #{inspect(reason)}."
        {^pid, spec, restart_count} = List.keyfind(children, pid, 0)
        new_children = child_exited(children, {pid, spec, restart_count})
        loop(new_children)
    end
  end

  defp start_child({mod, func, args}) do
    {:ok, spawn_link(mod, func, args)}
  end

  defp child_exited(children, {pid, _spec, restart_count}) when restart_count >= @max_restarts do
    List.keydelete(children, pid, 0)
  end
  defp child_exited(children, {pid, spec, restart_count}) do
    IO.puts "Process terminated #{restart_count + 1} times. Restarting..."
    {:ok, child_pid} = start_child(spec)
    new_children = List.keydelete(children, pid, 0)
    [{child_pid, spec, restart_count + 1}|new_children]
  end

  defp kill_all(children) do
    children
    |> Enum.each(fn {pid, _spec, _restart_count} ->
      Process.exit(pid, :kill)
    end)
  end

  # Helpers

  defp call(pid, command) do
    send(pid, {:request, self(), command})

    receive do
      {:reply, reply} -> reply
    end
  end

  defp reply(pid, reply) do
    send(pid, {:reply, reply})
  end
end
