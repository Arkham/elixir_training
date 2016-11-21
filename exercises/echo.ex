defmodule Echo do
  def start do
    pid = spawn(__MODULE__, :loop, [])
    Process.register(pid, :echo)
    :ok
  end

  def stop do
    send(:echo, :stop)
    :ok
  end

  def print(message) do
    send(:echo, {:print, message})
    :ok
  end

  def loop do
    receive do
      {:print, message} ->
        IO.puts(message)
        loop()
      :stop ->
        :ok
    end
  end
end
