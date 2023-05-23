print("Number of command-line arguments received:", #arg)

print("Dumping command-line arguments...")
dump(arg)

print("Iterating over command-line arguments...")
for index, argument in ipairs(arg) do
	print(index, argument)
end