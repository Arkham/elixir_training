defmodule SimpleSup do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: :simple_sup)
  end

  def init([]) do
    children = [worker(SimpleSupTest, [], [])]
    supervise(children, [strategy: :simple_one_for_one])
  end
end

defmodule SimpleSupTest do
  def start_link(name) do
    pid = spawn_link(__MODULE__, :init, [name])
    {:ok, pid}
  end

  def init(name) do
    Process.register(self, name)
    IO.puts("#{inspect(name)} started")
    loop()
  end

  defp loop do
    receive do
      x -> x
    end
  end
end
