require Record

defmodule User do
  Record.defrecord :person, [name: nil, age: 0, phone: nil]
  Record.defrecordp :private_person, [age: 0]

  def test_create do
    joe = person([name: "Joe", phone: [1,2,3,4,5]])
    robert = person([name: "Robert"])

    IO.inspect joe
    IO.inspect robert
    :ok
  end

  def test_select_fields do
    p = person([name: "Mike"])

    IO.inspect p
    IO.puts person(p, :name)
    IO.puts person(p, :age)
    :ok
  end

  def test_update do
    p = person(name: "Mike")

    IO.inspect p
    IO.inspect person(p, age: 35)
    IO.inspect person(p, name: "Joe")
    :ok
  end

  def test_pattern_match do
    p = person(name: "Joe", age: 35, phone: [1,2,3])
    person(name: name, age: 35, phone: phone) = p

    IO.inspect p
    IO.inspect name
    IO.inspect phone
    :ok
  end

  def test_internal_representation do
    p = person(name: "Joe", age: 10)

    IO.inspect p
    IO.inspect {:person, "Joe", 10, nil}
    IO.inspect p === {:person, "Joe", 10, nil}
    :ok
  end

  def test_private_record do
    pp = private_person(age: 27)

    IO.inspect pp
  end
end
