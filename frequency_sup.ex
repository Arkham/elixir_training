defmodule FrequencySup do 
  use Supervisor

  @name :frequency_sup

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: @name)
  end

  def stop do
    Process.exit(Process.whereis(@name), :shutdown)
  end

  def init([]) do
    children = [worker(FrequencyGen, [], shutdown: 2000)]
    spec = [strategy: :one_for_one, max_restarts: 3, max_seconds: 15]
    supervise(children, spec)
  end
end
