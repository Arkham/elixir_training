defmodule Fussball do
  def start(mycountry, othercountry) do
    spawn(Fussball, :init, [mycountry, othercountry])
    spawn(Fussball, :init, [othercountry, mycountry])
    :ok
  end

  def stop(country) do
    Process.exit(Process.whereis(country), :normal)
  end

  def kickoff(country) do
    send(country, :kick)
    :ok
  end

  def init(mycountry, othercountry) do
    Process.flag(:trap_exit, true)

    try do
      Process.link(Process.whereis(othercountry))
    rescue e -> e
    end

    Process.register(self(), mycountry)
    loop(mycountry, othercountry)
  end

  defp loop(mycountry, othercountry) do
    receive do
      :stop ->
        :ok
      :save ->
        IO.puts("#{othercountry} just saved...")
        loop(mycountry, othercountry)
      :score ->
        IO.puts("Oh no! #{othercountry} just scored!!")
        loop(mycountry, othercountry)
      :kick ->
        :timer.sleep(500)
        case :rand.uniform(1000) do
          n when n > 800 ->
            IO.puts("#{mycountry} SAVES! And what a save!!")
            send(othercountry, :save)
            send(othercountry, :kick)
          n when n > 950 ->
              IO.puts("#{mycountry} SCORES!!")
              send(othercountry, :score)
          _ ->
            IO.puts("#{mycountry} kicks the ball...")
            send(othercountry, :kick)
        end
        loop(mycountry, othercountry)
      {:EXIT, _pid, reason} ->
        IO.puts("Got exit signal: #{inspect(reason)}")
        loop(mycountry, othercountry)
    end
  end
end
