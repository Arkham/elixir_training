defmodule Sequential do
  def sum(num) when num > 0 do
    sum(num, 0)
  end

  defp sum(0, acc), do: acc
  defp sum(num, acc) do
    sum(num - 1, acc + num)
  end

  def sum_interval(n, m) when n <= m do
    sum_interval(n, m, 0)
  end

  defp sum_interval(n, n, acc), do: acc + n
  defp sum_interval(n, m, acc) do
    sum_interval(n + 1, m, acc + n)
  end

  def create(num) when num > 0 do
    create(num, [])
  end

  defp create(0, acc), do: acc
  defp create(num, acc) do
    create(num - 1, [num | acc])
  end

  def reverse_create(num) when num > 0 do
    create(num) |> Enum.reverse
  end

  def print(num) when num > 1 do
    print(num, 1)
  end

  defp print(num, current) when current > num, do: :ok
  defp print(num, current) do
    IO.puts(current)
    print(num, current + 1)
  end

  def even_print(num) when num > 1 do
    even_print(num, 2)
  end
  defp even_print(num, current) when current > num, do: :ok
  defp even_print(num, current) do
    IO.puts(current)
    even_print(num, current + 2)
  end
end
