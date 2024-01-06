#pragma once

#include "LabSound/backends/AudioDevice_RtAudio.h"
#include "LabSound/LabSound.h"

#include <cstddef>
#include <cstdint>

// Equivalent to lab::AudioDeviceInfo, but using fixed list sizes for ease of use
typedef struct labsound_audio_device_info_t {
	int32_t index;
	char identifier[256];
	uint32_t num_output_channels;
	uint32_t num_input_channels;
	float supported_samplerates[32];
	float nominal_samplerate;
	bool is_default_output;
	bool is_default_input;
} labsound_audio_device_info_t;

typedef struct labsound_audio_stream_config_t {
	int32_t device_index;
	uint32_t desired_channels;
	float desired_samplerate;
} labsound_audio_stream_config_t;

static_assert(sizeof(labsound_audio_stream_config_t) == sizeof(lab::AudioStreamConfig));
static_assert(sizeof(labsound_audio_stream_config_t::device_index) == sizeof(lab::AudioStreamConfig::device_index));
static_assert(sizeof(labsound_audio_stream_config_t::desired_channels) == sizeof(lab::AudioStreamConfig::desired_channels));
static_assert(sizeof(labsound_audio_stream_config_t::desired_samplerate) == sizeof(lab::AudioStreamConfig::desired_samplerate));

// Opaque to LuaJIT
typedef lab::AudioDevice_RtAudio* labsound_audio_device_t;
typedef lab::AudioContext* labsound_audio_context_t;
typedef lab::AudioDestinationNode* labsound_destination_node_t;
typedef lab::GainNode* labsound_gain_node_t;
typedef lab::SampledAudioNode* labsound_sampled_audio_node_t;
typedef lab::AudioNode* labsound_audio_node_t;

struct static_labsound_exports_table {

	// AudioDevice
	size_t (*labsound_get_device_count)(void);
	bool (*labsound_get_device_info)(size_t device_index, labsound_audio_device_info_t* device_info);
	bool (*labsound_get_default_device_config)(labsound_audio_stream_config_t* input_config, labsound_audio_stream_config_t* output_config, bool with_input);
	labsound_audio_device_t (*labsound_device_create)(labsound_audio_stream_config_t* input_config, labsound_audio_stream_config_t* output_config);
	void (*labsound_device_destroy)(labsound_audio_device_t);

	// AudioContext
	labsound_audio_context_t (*labsound_context_create)(bool is_offline, bool auto_dispatch_events);
	void (*labsound_context_destroy)(labsound_audio_context_t context);
	bool (*labsound_context_connect)(labsound_audio_context_t context, labsound_audio_node_t destination, labsound_audio_node_t source, int destinationIndex, int sourceIndex);
	bool (*labsound_context_disconnect)(labsound_audio_context_t context, labsound_audio_node_t destination, labsound_audio_node_t source, int destinationIndex, int sourceIndex);

	// AudioDestinationNode
	labsound_destination_node_t (*labsound_destination_node_create)(labsound_audio_context_t context, labsound_audio_device_t device);
	void (*labsound_destination_node_destroy)(labsound_destination_node_t destination_node);

	// GainNode
	labsound_gain_node_t (*labsound_gain_node_create)(labsound_audio_context_t context);
	void (*labsound_gain_node_destroy)(labsound_gain_node_t gain_node);
	bool (*labsound_gain_node_set_value)(labsound_gain_node_t gain_node, float gain_value);

	// SampledAudioNode
	labsound_sampled_audio_node_t (*labsound_sampled_audio_node_from_file)(labsound_audio_context_t context, const char* file_path, bool mix_to_mono);
	labsound_sampled_audio_node_t (*labsound_sampled_audio_node_from_memory)(labsound_audio_context_t context, const char* file_contents, size_t file_size, bool mix_to_mono);
	void (*labsound_sampled_audio_node_destroy)(labsound_sampled_audio_node_t sampled_audio_node);
	bool (*labsound_sampled_audio_node_start)(labsound_sampled_audio_node_t sampled_audio_node, float when, int loopCount);
	bool (*labsound_sampled_audio_node_stop)(labsound_sampled_audio_node_t sampled_audio_node, float when);

	// Miscellaneous utilities (could probably use some streamlining)
	void (*labsound_log_set_quiet)(int quiet_flag);
	void (*labsound_print_graph)(labsound_audio_node_t root_node);
};

namespace labsound_ffi {
	void* getExportsTable();
}

constexpr bool DEBUG_LABSOUND_BINDINGS = false;

template <typename... Args>
constexpr void LABSOUND_DEBUG_TRACE(Args&&... args) {
	if constexpr(DEBUG_LABSOUND_BINDINGS) {
		printf("[LabSound] ");
		printf(std::forward<Args>(args)...);
		printf("\n");
	}
}