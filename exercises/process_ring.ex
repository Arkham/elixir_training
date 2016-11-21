defmodule ProcessRing do
  def create(n) when n > 1 do
    create(n, [])
  end

  defp create(n, []) do
    first = spawn(__MODULE__, :loop, [self])
    create(n - 1, [first])
  end
  defp create(1, [head|_] = ring) do
    pid = spawn(__MODULE__, :loop, [head])
    # Close the ring by connecting first and last
    send List.last(ring), {:set_next, pid}
    [pid|ring]
  end
  defp create(n, [head|_] = ring) do
    pid = spawn(__MODULE__, :loop, [head])
    create(n - 1, [pid|ring])
  end

  def loop(next) do
    receive do
      {:message, message} ->
        :timer.sleep(1000)
        IO.puts "[#{inspect(self)}] Received message: #{message}. Forwarding to #{inspect(next)}."
        send(next, {:message, message})
        loop(next)
      {:set_next, new_next} ->
        loop(new_next)
      :quit ->
        IO.puts "[#{inspect(self)}] Received quit, quitting."
        send(next, :quit)
        :ok
    end
  end
end
