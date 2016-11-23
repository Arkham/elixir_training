bin = <<1, 2, 3>>
IO.inspect :erlang.binary_to_list(bin)

IO.inspect <<1,2,3::size(16)>>

IO.inspect <<5::size(4), 5::size(4)>>

<<int1::size(2), int2::size(6)>> = <<128>>
IO.inspect {int1, int2}

IO.inspect <<5::size(2), 5::size(8)>>

a = 1
b = <<a, 17, 42::size(16)>>
<<d::size(16), e, f::binary>> = b
IO.inspect([d,e,f])

<<x::size(7), y::size(1)>> = <<42>>
IO.inspect <<42>>
IO.inspect {x, y}
