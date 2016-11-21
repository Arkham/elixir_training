defmodule MyDb do
  def start do
    pid = spawn(__MODULE__, :loop, [Db.new()])
    Process.register(pid, :my_db)
    :ok
  end

  def stop, do: call(:stop)
  def write(key, element), do: call({:write, key, element})
  def delete(key), do: call({:delete, key})
  def read(key), do: call({:read, key})
  def match(element), do: call({:match, element})

  def loop(db) do
    receive do
      {:request, pid, :stop} ->
        Db.destroy(db)
        reply(pid, :ok)
      {:request, pid, {:write, key, element}} ->
        new = Db.write(db, key, element)
        reply(pid, :ok)
        loop(new)
      {:request, pid, {:delete, key}} ->
        new = Db.delete(db, key)
        reply(pid, :ok)
        loop(new)
      {:request, pid, {:read, key}} ->
        reply(pid, Db.read(db, key))
        loop(db)
      {:request, pid, {:match, value}} ->
        reply(pid, Db.match(db, value))
        loop(db)
    end
  end

  defp call(command) do
    send(:my_db, {:request, self(), command})

    receive do
      {:reply, reply} -> reply
    end
  end

  defp reply(pid, message) do
    send(pid, {:reply, message})
  end
end
