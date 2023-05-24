print("Number of command-line arguments received:", #arg)

print("Iterating over command-line arguments...")
for index, argument in ipairs(arg) do
	print(index, argument)
end