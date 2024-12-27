#include "interop_ffi.hpp"

#include <queue>

deferred_event_queue_t queue_create() {
	return new std::queue<deferred_event_t>();
}

size_t queue_size(const deferred_event_queue_t queue) {
	if(!queue) return 0;

	return queue->size();
}

bool queue_push_event(deferred_event_queue_t queue, deferred_event_t event) {
	if(!queue) return false;

	queue->push(event);

	return true;
}

deferred_event_t queue_pop_event(deferred_event_queue_t queue) {
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

void queue_destroy(deferred_event_queue_t queue) {
	delete queue;
}

namespace interop_ffi {

	void* getExportsTable() {
		static struct static_interop_exports_table exports = {
			.queue_create = &queue_create,
			.queue_size = &queue_size,
			.queue_push_event = &queue_push_event,
			.queue_pop_event = &queue_pop_event,
			.queue_destroy = &queue_destroy,
		};

		return &exports;
	}

}
