defmodule Pingpong do
  def start() do
    Process.register(spawn(Pingpong, :init_a, []), :a)
    Process.register(spawn(Pingpong, :init_b, []), :b)
    :ok
  end

  def stop() do
    Process.exit(Process.whereis(:a), :no_more_ping)
  end

  def send(n) do
    send(:a, {:msg, :message, n})
    :ok
  end

  def init_a() do
    loop_a()
  end

  def init_b() do
    # Process.link(Process.whereis(:a))
    loop_b()
  end

  defp loop_a() do
    receive do
      :stop ->
        blow_up()
      {:msg, _msg, 0} ->
        loop_a()
      {:msg, msg, n} ->
        IO.puts("ping...")
        :timer.sleep(500)
        send(:b, {:msg, msg, n - 1})
        loop_a()
    after
      15000 ->
        IO.puts("Ping got bored, exiting.")
        exit(:timeout)
    end
  end

  defp loop_b() do
    receive do
      :stop ->
        :ok
      {:msg, _msg, 0} ->
        loop_b()
      {:msg, msg, n} ->
        IO.puts("pong!")
        :timer.sleep(500)
        send(:a, {:msg, msg, n - 1})
        loop_b()
    after
      15000 ->
        IO.puts("Pong got bored, exiting.")
        exit(:timeout)
    end
  end
end
