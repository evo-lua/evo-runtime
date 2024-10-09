#include "lua.hpp"

// This is a modified version of the original lua-rapidjson encoder (see license text below)
// Copyright (C) 2015 Xpol Wan

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#include <algorithm>
#include <vector>

// lua-rapidjson
#include "luax.hpp"
#include "values.hpp"

// rapidjson
#include "rapidjson/prettywriter.h"
#include "rapidjson/rapidjson.h"

using namespace rapidjson;

struct Key {
	Key(const char* k, SizeType l)
		: key(k)
		, size(l) {}
	bool operator<(const Key& rhs) const {
		return strcmp(key, rhs.key) < 0;
	}
	const char* key;
	SizeType size;
};

class CustomizedEncoder {
	bool pretty;
	bool prettier;
	bool sort_keys;
	bool empty_table_as_array;
	int max_depth;
	static const int MAX_DEPTH_DEFAULT = 128;

public:
	CustomizedEncoder(lua_State* L, int opt)
		: pretty(false)
		, prettier(false)
		, sort_keys(false)
		, empty_table_as_array(false)
		, max_depth(MAX_DEPTH_DEFAULT) {
		if(lua_isnoneornil(L, opt))
			return;
		luaL_checktype(L, opt, LUA_TTABLE);

		pretty = luax::optboolfield(L, opt, "pretty", false);
		prettier = luax::optboolfield(L, opt, "prettier", false);
		sort_keys = luax::optboolfield(L, opt, "sort_keys", false);
		empty_table_as_array = luax::optboolfield(L, opt, "empty_table_as_array", false);
		max_depth = luax::optintfield(L, opt, "max_depth", MAX_DEPTH_DEFAULT);
	}

private:
	template <typename Writer>
	void encodeBoolean(lua_State* L, Writer* writer, int idx) {
		writer->Bool(lua_toboolean(L, idx) != 0);
	}

	template <typename Writer>
	void encodeNumber(lua_State* L, Writer* writer, int idx) {
		int64_t integer;
		if(luax::isinteger(L, idx, &integer))
			writer->Int64(integer);
		else {
			if(!writer->Double(lua_tonumber(L, idx)))
				luaL_error(L, "error while encode double value.");
		}
	}

	template <typename Writer>
	void encodeString(lua_State* L, Writer* writer, int idx) {
		size_t len;
		const char* s = lua_tolstring(L, idx, &len);
		writer->String(s, static_cast<SizeType>(len));
	}

	template <typename Writer>
	void encodeValue(lua_State* L, Writer* writer, int idx, int depth = 0) {
		int t = lua_type(L, idx);
		switch(t) {
		case LUA_TBOOLEAN:
			encodeBoolean(L, writer, idx);
			break;
		case LUA_TNUMBER:
			encodeNumber(L, writer, idx);
			break;
		case LUA_TSTRING:
			encodeString(L, writer, idx);
			break;
		case LUA_TTABLE:
			encodeTable(L, writer, idx, depth + 1);
			break;
		case LUA_TNIL:
			writer->Null();
			break;
		case LUA_TLIGHTUSERDATA:
			if(values::isnull(L, idx)) {
				writer->Null();
				break;
			}
			[[fallthrough]];
		default:
			if(!luaL_callmeta(L, idx, "__tostring")) { // Not a serializable object
				lua_pushvalue(L, idx);
				lua_pushstring(L, "tostring");
				lua_gettable(L, LUA_GLOBALSINDEX);
				lua_pushvalue(L, -2);
				lua_call(L, 1, 1);
				const char* stringifiedValue = lua_tostring(L, -1);
				if(stringifiedValue == nullptr) stringifiedValue = "nil";
				lua_pop(L, 2);

				lua_pushfstring(L, "Cannot encode value %s (only JSON-compatible primitive types are supported)", stringifiedValue);
				lua_error(L);
			}

			// While this isn't reversible, assume __tostring was set on purpose (serializable object)
			encodeString(L, writer, -1);
			lua_pop(L, 1);
		}
	}

	template <typename Writer>
	void encodeTable(lua_State* L, Writer* writer, int idx, int depth) {
		if(depth > max_depth)
			luaL_error(L, "nested too depth");

		if(!lua_checkstack(L, 4)) // requires at least 4 slots in stack: table, key, value, key
			luaL_error(L, "stack overflow");

		idx = luax::absindex(L, idx);
		if(values::isarray(L, idx, empty_table_as_array)) {
			encodeArray(L, writer, idx, depth);
			return;
		}

		// is object.
		if(!sort_keys) {
			encodeObject(L, writer, idx, depth);
			return;
		}

		std::vector<Key> keys;
		keys.reserve(luax::rawlen(L, idx));
		lua_pushnil(L); // [nil]
		while(lua_next(L, idx)) {
			// [key, value]

			if(lua_type(L, -2) == LUA_TSTRING) {
				size_t len = 0;
				const char* key = lua_tolstring(L, -2, &len);
				keys.push_back(Key(key, static_cast<SizeType>(len)));
			}

			// pop value, leaving original key
			lua_pop(L, 1);
			// [key]
		}
		// []
		encodeObject(L, writer, idx, depth, keys);
	}

	template <typename Writer>
	void encodeObject(lua_State* L, Writer* writer, int idx, int depth) {
		idx = luax::absindex(L, idx);
		writer->StartObject();

		// []
		lua_pushnil(L); // [nil]
		while(lua_next(L, idx)) {
			// [key, value]
			if(lua_type(L, -2) == LUA_TSTRING) {
				size_t len = 0;
				const char* key = lua_tolstring(L, -2, &len);
				writer->Key(key, static_cast<SizeType>(len));
				encodeValue(L, writer, -1, depth);
			}

			// pop value, leaving original key
			lua_pop(L, 1);
			// [key]
		}
		// []
		writer->EndObject();
	}

	template <typename Writer>
	void encodeObject(lua_State* L, Writer* writer, int idx, int depth, std::vector<Key>& keys) {
		// []
		idx = luax::absindex(L, idx);
		writer->StartObject();

		std::sort(keys.begin(), keys.end());

		std::vector<Key>::const_iterator i = keys.begin();
		std::vector<Key>::const_iterator e = keys.end();
		for(; i != e; ++i) {
			writer->Key(i->key, static_cast<SizeType>(i->size));
			lua_pushlstring(L, i->key, i->size); // [key]
			lua_gettable(L, idx); // [value]
			encodeValue(L, writer, -1, depth);
			lua_pop(L, 1); // []
		}
		// []
		writer->EndObject();
	}

	template <typename Writer>
	void encodeArray(lua_State* L, Writer* writer, int idx, int depth) {
		// []
		idx = luax::absindex(L, idx);
		writer->StartArray();
		int MAX = static_cast<int>(luax::rawlen(L, idx)); // lua_rawlen always returns value >= 0
		for(int n = 1; n <= MAX; ++n) {
			lua_rawgeti(L, idx, n); // [element]
			encodeValue(L, writer, -1, depth);
			lua_pop(L, 1); // []
		}
		writer->EndArray();
		// []
	}

public:
	template <typename Stream>
	void encode(lua_State* L, Stream* s, int idx) {
		if(prettier) {
			PrettyWriter writer(*s);
			writer.SetIndent('\t', 1);
			encodeValue(L, &writer, idx);
		} else if(pretty) {
			PrettyWriter<Stream> writer(*s);
			encodeValue(L, &writer, idx);
		} else {
			Writer<Stream> writer(*s);
			encodeValue(L, &writer, idx);
		}
	}
};

extern "C" {
int luaopen_rapidjson(lua_State* L); // Declared here because there's no header to include
}

static int json_encode_custom(lua_State* L) {
	CustomizedEncoder encode(L, 2);
	StringBuffer s;
	encode.encode(L, &s, 1);
	lua_pushlstring(L, s.GetString(), s.GetSize());
	return 1;
}

int json_get_version_string(lua_State* L) {
	lua_pushstring(L, RAPIDJSON_VERSION_STRING);
	return 1;
}

//  Intendation with four spaces is hardcoded in lua-rapidjson, but tabs are objectively superior (and less wasteful)
extern "C" {
int luaopen_rapidjson_modified(lua_State* L) {
	int success = luaopen_rapidjson(L);
	if(success != 1) {
		luaL_error(L, "Could not open rapidjson");
	}

	lua_pushcfunction(L, json_encode_custom);
	lua_setfield(L, -2, "encode");

	lua_pushcfunction(L, json_get_version_string);
	lua_setfield(L, -2, "version");

	return success;
}
}
