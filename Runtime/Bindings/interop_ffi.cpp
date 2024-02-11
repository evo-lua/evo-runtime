#include "interop_ffi.hpp"
#include "macros.hpp"

#include <queue>
#include <string>

std::queue<deferred_event_t>* queue_create() {
	return new std::queue<deferred_event_t>();
}

size_t queue_size(std::queue<deferred_event_t>* queue) {
	if(!queue) return 0;

	return queue->size();
}

bool queue_push_event(std::queue<deferred_event_t>* queue, deferred_event_t event) {
	if(!queue) return false;

	queue->push(event);

	return true;
}

deferred_event_t queue_pop_event(std::queue<deferred_event_t>* queue) {
	if(queue->empty()) {
		error_event_t error_details;
		error_details.type = ERROR_EVENT;
		error_details.code = ERROR_POPPING_EMPTY_QUEUE;

		deferred_event_t error_event;
		error_event.error_details = error_details;
		return error_event;
	}

	deferred_event_t event = queue->front();
	queue->pop();
	return event;
}

void queue_destroy(std::queue<deferred_event_t>* queue) {
	delete queue;
}

EMBED_BINARY(interop_aliased_types, "Runtime/Bindings/interop_aliases.h")
EMBED_BINARY(interop_exported_types, "Runtime/Bindings/interop_exports.h")

namespace interop_ffi {

	std::string getTypeDefinitions() {
		size_t totalSize = interop_aliased_types_size + interop_exported_types_size + 1;

		std::string cdefs;
		cdefs.reserve(totalSize);

		cdefs.append(interop_aliased_types, interop_aliased_types_size);
		cdefs.append("\n");
		cdefs.append(interop_exported_types, interop_exported_types_size);

		return cdefs;
	}

	void* getExportsTable() {
		static struct static_interop_exports_table exports_table;

		exports_table.queue_create = &queue_create;
		exports_table.queue_destroy = &queue_destroy;
		exports_table.queue_size = &queue_size;
		exports_table.queue_push_event = &queue_push_event;
		exports_table.queue_pop_event = &queue_pop_event;

		return &exports_table;
	}

}
