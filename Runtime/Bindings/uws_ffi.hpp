#pragma once

#include "uws.hpp"
#include "uws_exports.h"

#include <string>

namespace uws_ffi {
	const char* getTypeDefinitions();
	void* getExportsTable();
	uWS::Loop* assignEventLoop(void* existing_native_loop);
	void unassignEventLoop(uWS::Loop* uwsEventLoop);
	std::string opCodeToString(uWS::OpCode opCode);
	std::string compressOptionsToString(uWS::CompressOptions compressOption);
}