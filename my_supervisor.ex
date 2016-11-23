defmodule MySupervisor do
  def start(name, child_spec_list) do
    pid = spawn(__MODULE__, :init, [child_spec_list])
    Process.register(pid, name)
  end

  def stop(name), do: send(name, :stop)

  def init(child_spec_list) do
    Process.flag(:trap_exit, true)
    loop(start_children(child_spec_list, []))
  end

  def start_children([], acc), do: acc
  def start_children([{m, f, a} | child_spec_list], acc) do
    {:ok, pid} = apply(m, f, a)
    start_children(child_spec_list, [{pid, {m, f, a}} | acc])
  end

  def loop(child_list) do
    receive do
      {:EXIT, pid, _reason} ->
        new_child_list = restart_child(pid, child_list)
        loop(new_child_list)
      :stop ->
        terminate(child_list)
    end
  end

  def restart_child(pid, child_list) do
    {pid, {m, f, a}} = List.keyfind(child_list, pid, 0)
    {:ok, new_pid} = apply(m, f, a)
    [{new_pid, {m, f, a}} | List.keydelete(child_list, pid, 0)]
  end

  def terminate([]), do: :ok
  def terminate([{pid, _} | child_list]) do
    Process.exit(pid, :kill)
    terminate(child_list)
  end
end

defmodule MySupervisorTest do
  def start(name) do
    {:ok, spawn_link(__MODULE__, :init, [name])}
  end

  def init(name) do
    Process.register(self(), name)
    IO.puts("Started #{name}")
    loop()
  end

  def loop() do
    receive do
      :stop -> exit(:byebye)
    end
  end
end
