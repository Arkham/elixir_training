defmodule Echo do
  def go do
    pid = spawn(Echo, :loop, [])
    Process.register(pid, :echo)

    send(pid, {self(), :hello})
    receive do
      {^pid, msg} ->
        IO.puts(inspect(msg))
    end
  end

  def loop do
    receive do
      {from, msg} ->
        send(from, {self(), msg})
        loop()
      :stop ->
        :ok
    end
  end
end
