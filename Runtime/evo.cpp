#include "evo.hpp"
#include "macros.hpp"

#include <iostream>

void PrintRuntimeError(std::string message, std::string reason, std::string recommendedAction, std::string sourceLocation) {
	std::cerr << std::endl;

	std::printf("Oh no! Something went horribly wrong :(");
	std::cerr << std::endl;
	std::cerr << std::endl;

	std::printf("Here's some more details about the context:");
	std::cerr << std::endl;
	std::cerr << std::endl;

	std::printf("* Message: \t\t%s\n", message.c_str());
	std::printf("* Source Location: \t%s\n", sourceLocation.c_str());
	std::printf("* Why did it happen: \t%s\n", reason.c_str());
	std::printf("* What you can do: \t%s\n", recommendedAction.c_str());
}