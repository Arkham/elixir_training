defmodule Lists do
  # Write a function which given a list of integers and an integer, will return
  # all integers smaller than or equal to that integer.
  def filter(list, value) do
    filter(list, value, [])
  end
  defp filter([], _value, result), do: result |> Enum.reverse
  defp filter([h|t], value, result) when h <= value do
    filter(t, value, [h|result])
  end
  defp filter([_|t], value, result), do: filter(t, value, result)

  def reverse(list) do
    reverse(list, [])
  end
  defp reverse([], result), do: result
  defp reverse([h|t], result), do: reverse(t, [h|result])

  def concatenate(lists) do
    concatenate(lists, [])
  end
  defp concatenate([], result), do: result |> Enum.reverse
  defp concatenate([list|lists], result) do
    concatenate(lists, concatenate_list(list, result))
  end

  defp concatenate_list([], result), do: result
  defp concatenate_list([h|t], result) do
    concatenate_list(t, [h|result])
  end

  def flatten(lists) do
    flatten(lists, [])
  end
  def flatten([], result), do: result |> Enum.reverse
  def flatten([h|t], result) when is_list(h) do
    concatenate([flatten(h, result), flatten(t)])
  end
  def flatten([h|t], result) do
    flatten(t, [h|result])
  end
end
