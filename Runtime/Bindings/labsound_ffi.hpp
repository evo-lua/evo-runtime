#pragma once

#include "LabSound/backends/AudioDevice_RtAudio.h"
#include "LabSound/LabSound.h"

#include <cstddef>
#include <cstdint>

// Opaque to LuaJIT
typedef lab::AudioDevice_RtAudio* labsound_audio_device_t;
typedef lab::AudioContext* labsound_audio_context_t;
typedef lab::AudioDestinationNode* labsound_destination_node_t;
typedef lab::GainNode* labsound_gain_node_t;
typedef lab::PannerNode* labsound_panner_node_t;
typedef lab::SampledAudioNode* labsound_sampled_audio_node_t;
typedef lab::AudioNode* labsound_audio_node_t;

#include "labsound_exports.h"

// Basic sanity checks
static_assert(lab::PanningModel::PANNING_NONE == 0);
static_assert(lab::PanningModel::EQUALPOWER == 1);
static_assert(lab::PanningModel::HRTF == 2);

static_assert(lab::PannerNode::DistanceModel::LINEAR_DISTANCE == 0);
static_assert(lab::PannerNode::DistanceModel::INVERSE_DISTANCE == 1);
static_assert(lab::PannerNode::DistanceModel::EXPONENTIAL_DISTANCE == 2);

static_assert(sizeof(labsound_audio_stream_config_t) == sizeof(lab::AudioStreamConfig));
static_assert(sizeof(labsound_audio_stream_config_t::device_index) == sizeof(lab::AudioStreamConfig::device_index));
static_assert(sizeof(labsound_audio_stream_config_t::desired_channels) == sizeof(lab::AudioStreamConfig::desired_channels));
static_assert(sizeof(labsound_audio_stream_config_t::desired_samplerate) == sizeof(lab::AudioStreamConfig::desired_samplerate));

namespace labsound_ffi {
	const char* getTypeDefinitions();
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