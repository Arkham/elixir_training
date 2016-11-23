defmodule Syntax do
  def foo(42), do: {:ok, 42}
  def foo(_), do: {:error}

  def bar(x, 99), do: x + 101

  def baz(y), do: {:ok, y}

  def test do
    with {:ok, x} <- foo(41),
      y = bar(x, 99),
      {:ok, z} <- baz(y)
    do
      IO.puts "All good! x is #{x}, y is #{y} and z is #{z}"
    end
  end

  defmacro early_macro(expr) do
    IO.write "[EARLY] "
    IO.inspect expr
  end

  defmacro lazy_macro(expr) do
    quote do
      IO.write "[LAZY] "
      IO.inspect unquote(expr)
    end
  end

  def test_early_macro do
    early_macro(1)
    early_macro("string")
    early_macro({1,2})
    early_macro({1,2,3})
    early_macro Enum.map([1,2,3], &(&1*2))
  end

  def test_lazy_macro do
    lazy_macro(1)
    lazy_macro("string")
    lazy_macro({1,2})
    lazy_macro({1,2,3})
    lazy_macro Enum.map([1,2,3], &(&1*2))
  end

  defmacro my_unless(expr, options) do
    quote do: if(!unquote(expr), unquote(options))
  end

  def test_my_unless do
    my_unless true, do: IO.puts("passed false, running")
    my_unless false, do: IO.puts("passed false, running")
  end

  defmacro change(val) do
    local = "some value"

    inject = quote do
      local = unquote(val)
      IO.puts "At the end of the macro body: local = #{local}"
    end

    IO.puts "In macro definition: local = #{local}"
    inject
  end

  def test_hygienic_macro do
    local = "hello"
    change("FOOBAR")
    IO.puts local
  end
end
