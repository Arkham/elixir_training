defmodule Person do
  defstruct [name: nil,
             age: 0,
             phone: nil]
end

defmodule PersonTest do
  def test_create do
    person = %Person{name: "Joe", phone: [1,2,3,4]}

    IO.inspect person
    IO.inspect person.name
    IO.inspect person.age

    try do
      person.addr
    rescue
      KeyError -> IO.puts "Error raised when accessing undefined field"
    end

    :ok
  end

  def test_update do
    p = %Person{name: "Mike"}

    IO.inspect p
    IO.inspect %{p | age: 35}
    IO.inspect %{p | name: "Joe"}

    try do
      %{p | addr: "home"}
    rescue
      KeyError -> IO.puts "Error raised when trying to update an undefined field"
    end
  end

  def test_pattern_matching do
    p = %Person{name: "Joe", age: 35, phone: [1,2,3,4]}
    %Person{name: name, age: 35, phone: phone} = p

    IO.inspect p
    IO.inspect name
    IO.inspect phone

    %{name: ^name, age: 35, phone: ^phone} = p
  end

  def test_internal_representation do
    p = %Person{name: "Ju", age: 10, phone: "yes"}
    map = %{:__struct__ => Person, name: "Ju", age: 10, phone: "yes"}

    IO.inspect p
    IO.inspect map
    IO.inspect p === map
  end
end
