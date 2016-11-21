defmodule Db do
  def new, do: []

  def destroy(_db), do: :ok

  def write([], key, element) do
    [{key, element}]
  end
  def write([{key, _value} | db], key, element) do
    [{key, element} | db]
  end
  def write([current | db], key, element) do
    [current | write(db, key, element)]
  end

  def delete([{key, _value} | db], key), do: db
  def delete([current | db], key) do
    [current | delete(db, key)]
  end

  def read([{key, value} | _db], key) do
    {:ok, value}
  end
  def read([_current | db], key) do
    read(db, key)
  end
  def read(_db, _key) do
    {:error, :instance}
  end

  def match(db, value) do
    match(db, value, [])
  end
  defp match([], _value, result), do: result |> Enum.reverse
  defp match([{key, value} | db], value, result) do
    match(db, value, [key|result])
  end
  defp match([_current | db], value, result) do
    match(db, value, result)
  end
end
