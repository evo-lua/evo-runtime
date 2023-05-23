local arguments = { ... }

print("Number of command-line arguments received:", #arguments)

print("Dumping command-line arguments...")
dump(arguments)

print("Iterating over command-line arguments...")
for index, argument in pairs(arguments) do
	print(index, argument)
end