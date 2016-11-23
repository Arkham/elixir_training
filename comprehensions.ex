IO.inspect(for x <- [1,2,3,4], x < 3, do: x)
IO.inspect(for x <- [:zero, 1, :two, :three, 4, 5], is_integer(x), do: x)
IO.inspect(for x <- [1,2,3], y <- [:a,:b,:c], do: {x,y})
IO.inspect(for x <- [1,2,3,4], y <- [3,4,5,6], x == y, do: x)
IO.inspect(for x <- [1,2,3,4], rem(x, 2) == 0, do: x + 1)

defmodule Comprehensions do
  def map(list, fun) do
    for x <- list, do: fun.(x)
  end

  def filter(list, predicate) do
    for x <- list, predicate.(x), do: x
  end

  def append(list_of_lists) do
    for list <- list_of_lists, x <- list, do: x
  end

  def perm([]), do: [[]]
  def perm(list) do
    for h <- list, t <- perm(list -- [h]), do: [h|t]
  end

  def test do
    IO.inspect(map([1,2,3,4], &(&1 * 2)))
    IO.inspect(filter([1,2,3,4], &(&1 > 2)))
    IO.inspect(append([[1,2],[3,4]]))
    IO.inspect(perm([1,2,3]))
  end

  def test_project do
    y = 2
    c = for x <- 1..3, into: %{}, do: {x, y}
    IO.inspect c
  end
end
