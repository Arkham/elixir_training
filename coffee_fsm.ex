defmodule CoffeeFsm do
  @name :coffee_fsm
  @timeout 30_000

  def start_link do
    :gen_fsm.start_link({:local, @name}, __MODULE__, [], [])
  end

  def init([]) do
    Hw.reboot()
    Hw.display("Make your selection")
    {:ok, :select, nil}
  end

  def tea, do: send_selection(:tea, 100)
  def espresso, do: send_selection(:espresso, 150)
  def americano, do: send_selection(:americano, 100)
  def cappuccino, do: send_selection(:cappuccino, 150)

  defp send_selection(sel, price) do
    :gen_fsm.send_event(@name, {:selection, sel, price})
  end

  def pay(coin), do: :gen_fsm.send_event(@name, {:pay, coin})
  def cancel, do: :gen_fsm.send_event(@name, :cancel)
  def cup_removed, do: :gen_fsm.send_event(@name, :cup_removed)

  def select({:selection, type, price}, _data) do
    Hw.display("Please pay: #{price}")
    {:next_state, :payment, {type, price, 0}}
  end
  def select({:pay, coin}, data) do
    Hw.return_change(coin)
    {:next_state, :select, data}
  end
  def select(_other, data) do
    {:next_state, :select, data}
  end

  def payment({:pay, coin}, {type, price, paid}) do
    if paid + coin >= price do
      Hw.display("Preparing drink")
      Hw.return_change(paid + coin - price)
      Hw.drop_cup()
      Hw.prepare(type)
      Hw.display("Remove drink")
      {:next_state, :remove, nil}
    else
      new_paid = paid + coin
      Hw.display("Please pay: #{price - new_paid}")
      {:next_state, :payment, {type, price, new_paid}, @timeout}
    end
  end
  def payment(:cancel, {_type, _price, paid}) do
    Hw.display("Make your selection")
    Hw.return_change(paid)
    {:next_state, :select, nil}
  end
  def payment(:timeout, {_type, _price, paid}) do
    Hw.display("Make your selection")
    Hw.return_change(paid)
    {:next_state, :select, nil}
  end
  def payment(_other, data) do
    {:next_state, :payment, data, @timeout}
  end

  def remove(:cup_removed, data) do
    Hw.display("Make your selection")
    {:next_state, :select, data}
  end
  def remove({:pay, coin}, data) do
    Hw.return_change(coin)
    {:next_state, :remove, data}
  end
  def remove(_other, data) do
    {:next_state, :remove, data}
  end

  def stop, do: :gen_fsm.sync_send_event(@name, :stop)

  def select(:stop, _from, data) do
    {:stop, :normal, :ok, data}
  end
  def payment(:stop, _from, paid) do
    Hw.return_change(paid)
    {:stop, :normal, :ok, 0}
  end
  def remove(:stop, _from, data) do
    {:stop, :normal, :ok, data}
  end
  def terminate(_reason, _state, _data), do: :ok
end
