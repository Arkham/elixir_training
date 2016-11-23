# Creating
person = %{name: "Joe", phone: [1,2,3,4]}

# Reading
IO.inspect person
IO.inspect person[:name]
IO.inspect person.name
IO.inspect person[:addr]

try do
  person.addr
rescue
  KeyError -> IO.puts "Error raised when using shorthand for undefined property"
end

# Updating and inserting
IO.inspect %{person | name: "Ju"}

try do
  IO.inspect %{person | age: "Ju"}
rescue
  KeyError -> IO.puts "Error raised when updating a non-existent key"
end

IO.inspect Map.put(person, :age, 42)

# Pattern matching and pinning
%{name: name, phone: phone} = person
IO.inspect name
IO.inspect phone

key = :name
%{^key => ^name, phone: ^phone} = person

# Nesting
robert = %{name: %{"id" => 1, first: "Robert", last: "Virding"}}

IO.inspect robert
IO.inspect robert[:name]["id"]
IO.inspect robert.name.first
