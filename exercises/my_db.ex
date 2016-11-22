defmodule MyDb do
  ## Public API

  def start do
    pid = spawn(__MODULE__, :init, [])
    Process.register(pid, :my_db)
    {:ok, pid}
  end

  def stop, do: cast(:stop)
  def write(key, element), do: cast({:write, key, element})
  def delete(key), do: cast({:delete, key})
  def read(key), do: call({:read, key})
  def match(element), do: call({:match, element})
  def lock, do: call(:lock)
  def unlock, do: call(:unlock)

  ## Callbacks

  defp init do
    loop(Db.new())
  end

  defp loop(db) do
    receive do
      {:request, _pid, :stop} ->
        Db.destroy(db)
      {:request, _pid, {:write, key, element}} ->
        new = Db.write(db, key, element)
        loop(new)
      {:request, _pid, {:delete, key}} ->
        new = Db.delete(db, key)
        loop(new)
      {:request, pid, {:read, key}} ->
        reply(pid, Db.read(db, key))
        loop(db)
      {:request, pid, {:match, value}} ->
        reply(pid, Db.match(db, value))
        loop(db)
      {:request, pid, :lock} ->
        reply(pid, :ok)
        lock_loop(db, pid)
    end
  end

  defp lock_loop(db, owner) do
    receive do
      {:request, _pid, :stop} ->
        Db.destroy(db)
      {:request, ^owner, {:write, key, element}} ->
        new = Db.write(db, key, element)
        lock_loop(new, owner)
      {:request, ^owner, {:delete, key}} ->
        new = Db.delete(db, key)
        lock_loop(new, owner)
      {:request, ^owner, {:read, key}} ->
        reply(owner, Db.read(db, key))
        lock_loop(db, owner)
      {:request, ^owner, {:match, value}} ->
        reply(owner, Db.match(db, value))
        lock_loop(db, owner)
      {:request, ^owner, :unlock} ->
        reply(owner, :ok)
        loop(db)
    end
  end

  defp call(command) do
    send(:my_db, {:request, self(), command})

    receive do
      {:reply, reply} -> reply
    end
  end

  defp cast(command) do
    send(:my_db, {:request, self(), command})
    :ok
  end

  defp reply(pid, message) do
    send(pid, {:reply, message})
  end
end
