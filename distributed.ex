defmodule Distributed do
  def start do
    Process.register(self(), :server)
    loop()
  end

  def loop do
    receive do
      {pid, message} -> send(pid, message <> " world")
    end
    loop()
  end
end
