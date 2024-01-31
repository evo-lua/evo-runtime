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

typedef enum LabSoundPanningModel {
	LabSoundPanningModel_None = 0,
	LabSoundPanningModel_EqualPower = 1,
	LabSoundPanningModel_HRTF = 2,
} LabSoundPanningModel;

static_assert(lab::PanningModel::PANNING_NONE == 0);
static_assert(lab::PanningModel::EQUALPOWER == 1);
static_assert(lab::PanningModel::HRTF == 2);

typedef enum LabSoundDistanceModel {
	LabSoundDistanceModel_Linear = 0,
	LabSoundDistanceModel_Inverse = 1,
	LabSoundDistanceModel_Exponential = 2,
} LabSoundDistanceModel;

static_assert(lab::PannerNode::DistanceModel::LINEAR_DISTANCE == 0);
static_assert(lab::PannerNode::DistanceModel::INVERSE_DISTANCE == 1);
static_assert(lab::PannerNode::DistanceModel::EXPONENTIAL_DISTANCE == 2);

static_assert(sizeof(labsound_audio_stream_config_t) == sizeof(lab::AudioStreamConfig));
static_assert(sizeof(labsound_audio_stream_config_t::device_index) == sizeof(lab::AudioStreamConfig::device_index));
static_assert(sizeof(labsound_audio_stream_config_t::desired_channels) == sizeof(lab::AudioStreamConfig::desired_channels));
static_assert(sizeof(labsound_audio_stream_config_t::desired_samplerate) == sizeof(lab::AudioStreamConfig::desired_samplerate));

// Opaque to LuaJIT
typedef lab::AudioDevice_RtAudio* labsound_audio_device_t;
typedef lab::AudioContext* labsound_audio_context_t;
typedef lab::AudioDestinationNode* labsound_destination_node_t;
typedef lab::GainNode* labsound_gain_node_t;
typedef lab::PannerNode* labsound_panner_node_t;
typedef lab::SampledAudioNode* labsound_sampled_audio_node_t;
typedef lab::AudioNode* labsound_audio_node_t;

struct static_labsound_exports_table {

	const char* (*labsound_version)();

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
	bool (*labsound_context_load_hrtf_database)(labsound_audio_context_t context, const char* directory);
	void (*labsound_context_listener_set_forward)(labsound_audio_context_t context, float x, float y, float z);
	void (*labsound_context_listener_set_up_vector)(labsound_audio_context_t context, float x, float y, float z);
	void (*labsound_context_listener_set_position)(labsound_audio_context_t context, float x, float y, float z);
	void (*labsound_context_listener_set_velocity)(labsound_audio_context_t context, float x, float y, float z);
	void (*labsound_context_synchronize_connections)(labsound_audio_context_t context);

	// AudioDestinationNode
	labsound_destination_node_t (*labsound_destination_node_create)(labsound_audio_context_t context, labsound_audio_device_t device);
	void (*labsound_destination_node_destroy)(labsound_destination_node_t destination_node);

	// GainNode
	labsound_gain_node_t (*labsound_gain_node_create)(labsound_audio_context_t context);
	void (*labsound_gain_node_destroy)(labsound_gain_node_t gain_node);
	bool (*labsound_gain_node_set_value)(labsound_gain_node_t gain_node, float gain_value);

	// PannerNode
	labsound_panner_node_t (*labsound_panner_node_create)(labsound_audio_context_t context);
	void (*labsound_panner_node_destroy)(labsound_panner_node_t panner_node);
	void (*labsound_panner_node_set_velocity)(labsound_panner_node_t panner_node, float x, float y, float z);
	void (*labsound_panner_node_set_position)(labsound_panner_node_t panner_node, float x, float y, float z);
	void (*labsound_panner_node_set_orientation)(labsound_panner_node_t panner_node, float x, float y, float z);
	void (*labsound_panner_node_set_panning_model)(labsound_panner_node_t panner_node, LabSoundPanningModel panning_model);
	void (*labsound_panner_node_set_distance_model)(labsound_panner_node_t panner_node, LabSoundDistanceModel distance_model);
	void (*labsound_panner_node_set_ref_distance)(labsound_panner_node_t panner_node, float ref_distance);
	void (*labsound_panner_node_set_max_distance)(labsound_panner_node_t panner_node, float max_distance);
	void (*labsound_panner_node_set_rolloff_factor)(labsound_panner_node_t panner_node, float rollof_factor);
	void (*labsound_panner_node_set_cone_inner_angle)(labsound_panner_node_t panner_node, float angle);
	void (*labsound_panner_node_set_cone_outer_angle)(labsound_panner_node_t panner_node, float angle);
	void (*labsound_panner_node_set_cone_outer_gain)(labsound_panner_node_t panner_node, float angle);

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