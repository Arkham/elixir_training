defmodule Temp do
  def f2c(farenheiht) do
    (farenheiht - 32) * 5/9
  end

  def c2f(celsius) do
    celsius * 9/5 + 32
  end

  def convert({:c, celsius}), do: {:f, c2f(celsius)}
  def convert({:f, farenheiht}), do: {:c, f2c(farenheiht)}
end
