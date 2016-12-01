defmodule CoffeeMachine do
  @name :coffee_machine

  def start_link do
    spawn_link(__MODULE__, :init, [])
  end

  def init do
    Process.register(self, @name)
    Hw.reboot()
    select()
  end

  def tea, do: send_selection(:tea, 100)
  def espresso, do: send_selection(:espresso, 150)
  def americano, do: send_selection(:americano, 100)
  def cappuccino, do: send_selection(:cappuccino, 150)

  defp send_selection(sel, price) do
    send(@name, {:selection, sel, price})
  end

  def remove_drink, do: send(@name, :cup_removed)
  def pay(coin), do: send(@name, {:pay, coin})
  def cancel, do: send(@name, :cancel)

  def select do
    Hw.display("""
    Make your selection:
    * tea           100
    * espresso      150
    * americano     100
    * cappuccino    150
    """)

    receive do
      {:selection, type, price} ->
        payment(type, price, 0)

      {:pay, coin} ->
        Hw.return_change(coin)
        select()

      _other ->
        select()
    end
  end

  def payment(type, price, paid) do
    Hw.display("Please pay #{price - paid} or cancel")

    receive do
      {:pay, coin} ->
        if paid + coin >= price do
          Hw.return_change(paid + coin - price)
          Hw.drop_cup()
          Hw.prepare(type)
          remove()
        else
          new_paid = paid + coin
          payment(type, price, new_paid)
        end

      :cancel ->
        Hw.return_change(paid)
        select()

      _other ->
        payment(type, price, paid)
    end
  end

  def remove do
    Hw.display("Remove drink")

    receive do
      :cup_removed ->
        select()

      {:pay, coin} ->
        Hw.return_change(coin)
        remove()

      _other ->
        remove()
    end
  end
end

defmodule Hw do
  def reboot do
    IO.puts "[Rebooting]"
  end

  def display(message) do
    IO.puts "[Display] #{message}"
  end

  def return_change(0), do: true
  def return_change(coin) do
    IO.puts "[Returning #{coin}]"
  end

  def drop_cup do
    IO.puts "[Dropping cup]"
  end

  def prepare(type) do
    IO.puts "[Preparing #{type}...]"
  end
end
