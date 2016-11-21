defmodule CrossRing do
  def create(n) when n >= 3 do
    create(n, [])
  end

  defp create(n, []) do
    first = spawn(__MODULE__, :switch_loop, [[]])
    create(n, {first, [], []}, 1)
  end

  defp create(n, {first, [h1|_], [h2|_]} = ring, current) when current == n do
    send first, {:set_outputs, [h1, h2]}
    ring
  end
  defp create(n, {first, [], second_half}, current) when current < n/2 do
    pid = spawn(__MODULE__, :loop, [first])
    create(n, {first, [pid], second_half}, current + 1)
  end
  defp create(n, {first, [h|_] = first_half, second_half}, current) when current < n/2 do
    pid = spawn(__MODULE__, :loop, [h])
    create(n, {first, [pid|first_half], second_half}, current + 1)
  end
  defp create(n, {first, first_half, []}, current) when current >= n/2 do
    pid = spawn(__MODULE__, :loop, [first])
    create(n, {first, first_half, [pid]}, current + 1)
  end
  defp create(n, {first, first_half, [h|_] = second_half}, current) when current >= n/2 do
    pid = spawn(__MODULE__, :loop, [h])
    create(n, {first, first_half, [pid|second_half]}, current + 1)
  end

  def loop(next) do
    receive do
      :quit ->
        IO.puts "[#{inspect(self)}] Received quit. Propagating to #{inspect(next)} and quitting."
        send next, :quit
        :ok
      message ->
        :timer.sleep(1000)
        IO.puts "[#{inspect(self)}] Received message #{message}. Forwarding to #{inspect(next)}."
        send next, message
        loop(next)
    end
  end

  def switch_loop(outputs) do
    receive do
      :quit ->
        IO.puts "{SWITCH} [#{inspect(self)}] Received quit. Propagating to #{inspect(outputs)} and quitting."
        outputs
        |> Enum.each(fn output ->
          send output, :quit
        end)
        :ok

      {:set_outputs, outputs} ->
        switch_loop(outputs)

      message ->
        case outputs do
          [] ->
            IO.puts "{SWITCH} [#{inspect(self)}] Received message #{message}, but no outputs defined."
            switch_loop(outputs)
          [next|t] ->
            IO.puts "{SWITCH} [#{inspect(self)}] Received message #{message}. Forwarding to #{inspect(next)}."
            :timer.sleep(1000)
            send next, message
            switch_loop(t ++ [next])
        end
    end
  end
end
