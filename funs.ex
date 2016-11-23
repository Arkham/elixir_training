add = fn(x, y) -> x + y end
IO.puts add.(2,3)

special_add = fn(x, 42) ->
  "Answer to the universe and all"
  (x, y) ->
    x + y
end

IO.puts special_add.(2,3)
IO.puts special_add.(2,42)
