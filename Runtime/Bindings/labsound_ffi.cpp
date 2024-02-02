
#include "labsound_ffi.hpp"

#include "LabSound/backends/AudioDevice_RtAudio.h"
#include "LabSound/LabSound.h"

#include <cstddef>
#include <cstring>
#include <vector>

using namespace lab;

const char* labsound_version() {
	return LABSOUND_VERSION;
}

bool labsound_get_default_device_config(labsound_audio_stream_config_t* input_config, labsound_audio_stream_config_t* output_config, bool with_input) {
	if(!input_config) return false;
	if(!output_config) return false;

	const std::vector<AudioDeviceInfo> audioDevices = AudioDevice_RtAudio::MakeAudioDeviceList();
	AudioDeviceInfo defaultOutputInfo, defaultInputInfo;
	for(const auto& info : audioDevices) {
		if(info.is_default_output)
			defaultOutputInfo = info;
		if(info.is_default_input)
			defaultInputInfo = info;
	}

	AudioStreamConfig outputConfig;
	if(defaultOutputInfo.index != -1) {
		outputConfig.device_index = defaultOutputInfo.index;
		outputConfig.desired_channels = std::min(uint32_t(2), defaultOutputInfo.num_output_channels);
		outputConfig.desired_samplerate = defaultOutputInfo.nominal_samplerate;
	}

	AudioStreamConfig inputConfig;
	if(with_input) {
		if(defaultInputInfo.index != -1) {
			inputConfig.device_index = defaultInputInfo.index;
			inputConfig.desired_channels = std::min(uint32_t(1), defaultInputInfo.num_input_channels);
			inputConfig.desired_samplerate = defaultInputInfo.nominal_samplerate;
		} else return false;
	}

	// RtAudio doesn't support mismatched input and output rates
	if(defaultOutputInfo.nominal_samplerate != defaultInputInfo.nominal_samplerate) {
		float min_rate = std::min(defaultOutputInfo.nominal_samplerate, defaultInputInfo.nominal_samplerate);
		inputConfig.desired_samplerate = min_rate;
		outputConfig.desired_samplerate = min_rate;
		LABSOUND_DEBUG_TRACE("Input and output sample rates don't match; falling back to minimum of %f", min_rate);
	}

	input_config->device_index = inputConfig.device_index;
	input_config->desired_channels = inputConfig.desired_channels;
	input_config->desired_samplerate = inputConfig.desired_samplerate;

	output_config->device_index = outputConfig.device_index;
	output_config->desired_channels = outputConfig.desired_channels;
	output_config->desired_samplerate = outputConfig.desired_samplerate;

	return true;
}

size_t labsound_get_device_count() {
	// Slightly wasteful, but unlikely to ever be a problem
	const std::vector<AudioDeviceInfo> audioDevices = AudioDevice_RtAudio::MakeAudioDeviceList();
	return audioDevices.size();
}

bool labsound_get_device_info(size_t device_index, labsound_audio_device_info_t* device_info) {
	if(!device_info) return false;

	// Slightly wasteful, but unlikely to ever be a problem
	const std::vector<AudioDeviceInfo> audioDevices = AudioDevice_RtAudio::MakeAudioDeviceList();

	auto deviceInfo = audioDevices[device_index];
	auto deviceIdentifierLength = deviceInfo.identifier.size();

	// Dynamic C++ data structures may overrun fixed-size C structs (unlikely, but still)
	assert(deviceInfo.identifier.size() + 1 <= sizeof(device_info->identifier));
	assert(deviceInfo.supported_samplerates.size() <= sizeof(device_info->supported_samplerates));
	assert(deviceInfo.index == device_index); // Better safe than sorry...

	device_info->index = deviceInfo.index;

	std::strncpy(device_info->identifier, deviceInfo.identifier.c_str(), deviceIdentifierLength);
	device_info->identifier[deviceIdentifierLength] = '\0';

	device_info->num_output_channels = deviceInfo.num_output_channels;
	device_info->num_input_channels = deviceInfo.num_input_channels;

	for(size_t index = 0; index < deviceInfo.supported_samplerates.size(); index++) {
		device_info->supported_samplerates[index] = deviceInfo.supported_samplerates[index];
	}

	device_info->nominal_samplerate = deviceInfo.nominal_samplerate;
	device_info->is_default_output = deviceInfo.is_default_output;
	device_info->is_default_input = deviceInfo.is_default_input;

	return true;
}

labsound_audio_device_t labsound_device_create(labsound_audio_stream_config_t* input_config, labsound_audio_stream_config_t* output_config) {
	if(!input_config) return nullptr;
	if(!output_config) return nullptr;

	auto inputConfig = reinterpret_cast<AudioStreamConfig*>(input_config);
	auto outputConfig = reinterpret_cast<AudioStreamConfig*>(output_config);
	return new AudioDevice_RtAudio(*inputConfig, *outputConfig);
}

void labsound_device_destroy(labsound_audio_device_t device) {
	delete device;
}

labsound_audio_context_t labsound_context_create(bool is_offline, bool auto_dispatch_events) {
	return new AudioContext(is_offline, auto_dispatch_events);
}

void labsound_context_destroy(labsound_audio_context_t context) {
	delete context;
}

bool labsound_context_connect(labsound_audio_context_t context, labsound_audio_node_t destination, labsound_audio_node_t source, int destinationIndex, int sourceIndex) {
	if(!context) return false;
	if(!destination) return false;
	if(!source) return false;

	assert(destinationIndex >= 0);
	assert(sourceIndex >= 0);

	LABSOUND_DEBUG_TRACE("Connecting source %s (output %d) with destination %s (input %d)", source->name(), sourceIndex, destination->name(), destinationIndex);

	auto sharedDestinationPointer = std::shared_ptr<AudioNode>(destination, [](labsound_audio_node_t destination) {
		LABSOUND_DEBUG_TRACE("NOOP deleter from %s called for sharedDestinationPointer (%s)", "labsound_context_connect", destination->name());
	});
	auto sharedSourcePointer = std::shared_ptr<AudioNode>(source, [](labsound_audio_node_t source) {
		LABSOUND_DEBUG_TRACE("NOOP deleter from %s called for sharedSourcePointer (%s)", "labsound_context_connect", source->name());
	});

	context->connect(sharedDestinationPointer, sharedSourcePointer, destinationIndex, sourceIndex);

	return true;
}

bool labsound_context_disconnect(labsound_audio_context_t context, labsound_audio_node_t destination, labsound_audio_node_t source, int destinationIndex, int sourceIndex) {
	if(!context) return false;
	if(!destination) return false;
	if(!source) return false;

	assert(destinationIndex > 0);
	assert(sourceIndex > 0);

	LABSOUND_DEBUG_TRACE("Disconnecting source %s (output %d) from destination %s (input %d)", source->name(), sourceIndex, destination->name(), destinationIndex);

	auto sharedDestinationPointer = std::shared_ptr<AudioNode>(destination, [](labsound_audio_node_t destination) {
		LABSOUND_DEBUG_TRACE("NOOP deleter from %s called for sharedDestinationPointer (%s)", "labsound_context_disconnect", destination->name());
	});
	auto sharedSourcePointer = std::shared_ptr<AudioNode>(source, [](labsound_audio_node_t source) {
		LABSOUND_DEBUG_TRACE("NOOP deleter from %s called for sharedSourcePointer (%s)", "labsound_context_disconnect", source->name());
	});

	context->disconnect(sharedDestinationPointer, sharedSourcePointer, destinationIndex, sourceIndex);

	return true;
}

bool labsound_context_load_hrtf_database(labsound_audio_context_t context, const char* directory) {
	if(!context) return false;
	if(!directory) return false;

	LABSOUND_DEBUG_TRACE("Loading HRTF spatialization database from directory %s", directory);
	return context->loadHrtfDatabase(directory);
}

void labsound_context_listener_set_forward(labsound_audio_context_t context, float x, float y, float z) {
	if(!context) return;
	if(!context->listener()) return;

	context->listener()->setForward({ x, y, z });
}

void labsound_context_listener_set_up_vector(labsound_audio_context_t context, float x, float y, float z) {
	if(!context) return;
	if(!context->listener()) return;

	context->listener()->setUpVector({ x, y, z });
}

void labsound_context_listener_set_position(labsound_audio_context_t context, float x, float y, float z) {
	if(!context) return;
	if(!context->listener()) return;

	context->listener()->setPosition({ x, y, z });
}

void labsound_context_listener_set_velocity(labsound_audio_context_t context, float x, float y, float z) {
	if(!context) return;
	if(!context->listener()) return;

	context->listener()->setPosition({ x, y, z });
}

void labsound_context_synchronize_connections(labsound_audio_context_t context) {
	if(!context) return;

	context->synchronizeConnections();
}

labsound_destination_node_t labsound_destination_node_create(labsound_audio_context_t context, labsound_audio_device_t device) {
	if(!context) return nullptr;
	if(!device) return nullptr;

	auto sharedDevicePointer = std::shared_ptr<AudioDevice_RtAudio>(device, [](AudioDevice_RtAudio*) {
		LABSOUND_DEBUG_TRACE("NOOP deleter from %s called for sharedDevicePointer", "labsound_destination_node_create");
	});

	auto destinationNode = new AudioDestinationNode(*context, sharedDevicePointer);
	auto sharedDestinationNodePointer = std::shared_ptr<AudioDestinationNode>(destinationNode, [](AudioDestinationNode*) {
		LABSOUND_DEBUG_TRACE("NOOP deleter from %s called for sharedDestinationNodePointer", "labsound_destination_node_create");
	});

	// Assigning the node automatically might not fit every use case, but for now it's the most convenient option
	device->setDestinationNode(sharedDestinationNodePointer);
	context->setDestinationNode(sharedDestinationNodePointer);

	return destinationNode;
}

void labsound_destination_node_destroy(labsound_destination_node_t destination_node) {
	delete destination_node;
}

labsound_gain_node_t labsound_gain_node_create(labsound_audio_context_t context) {
	if(!context) return nullptr;

	return new GainNode(*context);
}

void labsound_gain_node_destroy(labsound_gain_node_t gain_node) {
	delete gain_node;
}

bool labsound_gain_node_set_value(labsound_gain_node_t gain_node, float gain_value) {
	if(!gain_node) return false;
	if(!gain_node->gain()) return false;

	gain_node->gain()->setValue(gain_value);

	return true;
}

labsound_panner_node_t labsound_panner_node_create(labsound_audio_context_t context) {
	if(!context) return nullptr;

	return new PannerNode(*context);
}

void labsound_panner_node_destroy(labsound_panner_node_t panner_node) {
	delete panner_node;
}

void labsound_panner_node_set_panning_model(labsound_panner_node_t panner_node, LabSoundPanningModel panning_model) {
	if(!panner_node) return;

	panner_node->setPanningModel(static_cast<lab::PanningModel>(panning_model));
}

void labsound_panner_node_set_velocity(labsound_panner_node_t panner_node, float x, float y, float z) {
	if(!panner_node) return;

	panner_node->setVelocity({ x, y, z });
}

void labsound_panner_node_set_position(labsound_panner_node_t panner_node, float x, float y, float z) {
	if(!panner_node) return;

	panner_node->setPosition({ x, y, z });
}

void labsound_panner_node_set_orientation(labsound_panner_node_t panner_node, float x, float y, float z) {
	if(!panner_node) return;

	panner_node->setOrientation({ x, y, z });
}

void labsound_panner_node_set_distance_model(labsound_panner_node_t panner_node, LabSoundDistanceModel distance_model) {
	if(!panner_node) return;

	panner_node->setDistanceModel(static_cast<lab::PannerNode::DistanceModel>(distance_model));
}

void labsound_panner_node_set_ref_distance(labsound_panner_node_t panner_node, float ref_distance) {
	if(!panner_node) return;

	panner_node->setRefDistance(ref_distance);
}

void labsound_panner_node_set_max_distance(labsound_panner_node_t panner_node, float max_distance) {
	if(!panner_node) return;

	panner_node->setMaxDistance(max_distance);
}

void labsound_panner_node_set_rolloff_factor(labsound_panner_node_t panner_node, float rollof_factor) {
	if(!panner_node) return;

	panner_node->setRolloffFactor(rollof_factor);
}

void labsound_panner_node_set_cone_inner_angle(labsound_panner_node_t panner_node, float angle) {
	if(!panner_node) return;

	panner_node->setConeInnerAngle(angle);
}

void labsound_panner_node_set_cone_outer_angle(labsound_panner_node_t panner_node, float angle) {
	if(!panner_node) return;

	panner_node->setConeOuterAngle(angle);
}

void labsound_panner_node_set_cone_outer_gain(labsound_panner_node_t panner_node, float angle) {
	if(!panner_node) return;

	panner_node->setConeOuterGain(angle);
}

labsound_sampled_audio_node_t labsound_sampled_audio_node_from_file(labsound_audio_context_t context, const char* file_path, bool mix_to_mono) {
	if(!context) return nullptr;
	if(!file_path) return nullptr;

	// In this case a NOOP deleter isn't needed as buses are managed by LabSound internally (and never by LuaJIT)
	auto sharedAudioBusPointer = MakeBusFromFile(file_path, mix_to_mono);
	if(!sharedAudioBusPointer) return nullptr;

	auto sampledAudioNode = new SampledAudioNode(*context);
	{
		ContextRenderLock renderLock(context, "labsound_sampled_audio_node_from_file");
		sampledAudioNode->setBus(renderLock, sharedAudioBusPointer);
	}

	return sampledAudioNode;
}

labsound_sampled_audio_node_t labsound_sampled_audio_node_from_memory(labsound_audio_context_t context, const char* file_contents, size_t file_size, bool mix_to_mono) {
	if(!context) return nullptr;
	if(!file_contents) return nullptr;

	// This copy may be redundant (need to investigate), but it's the safest option - review later
	std::vector<uint8_t> buffer(file_contents, file_contents + file_size);

	// In this case a NOOP deleter isn't needed as buses are managed by LabSound internally (and never by LuaJIT)
	auto sharedAudioBusPointer = MakeBusFromMemory(buffer, mix_to_mono);
	if(!sharedAudioBusPointer) return nullptr;

	auto sampledAudioNode = new SampledAudioNode(*context);
	{
		ContextRenderLock renderLock(context, "labsound_sampled_audio_node_from_file");
		sampledAudioNode->setBus(renderLock, sharedAudioBusPointer);
	}

	return sampledAudioNode;
}

void labsound_sampled_audio_node_destroy(labsound_sampled_audio_node_t sampled_audio_node) {
	delete sampled_audio_node;
}

// Should probably use the generic AudioScheduledSourceNode for all relevant nodes (once more are added)?
bool labsound_sampled_audio_node_start(labsound_sampled_audio_node_t sampled_audio_node, float when, int loopCount) {
	if(!sampled_audio_node) return false;

	sampled_audio_node->start(when, loopCount);

	return true;
}

bool labsound_sampled_audio_node_stop(labsound_sampled_audio_node_t sampled_audio_node, float when) {
	if(!sampled_audio_node) return false;

	sampled_audio_node->stop(when);

	return true;
}

void labsound_print_graph(labsound_audio_node_t root_node) {
	AudioNode::printGraph(root_node, [](const char* str) {
		printf("%s\n", str);
	});
}

namespace labsound_ffi {

	void* getExportsTable() {
		static struct static_labsound_exports_table exports_table;

		exports_table.labsound_version = &labsound_version;

		// AudioDevice
		exports_table.labsound_get_device_count = &labsound_get_device_count;
		exports_table.labsound_get_device_info = &labsound_get_device_info;
		exports_table.labsound_get_default_device_config = &labsound_get_default_device_config;
		exports_table.labsound_device_create = &labsound_device_create;
		exports_table.labsound_device_destroy = &labsound_device_destroy;

		// AudioContext
		exports_table.labsound_context_create = &labsound_context_create;
		exports_table.labsound_context_destroy = &labsound_context_destroy;
		exports_table.labsound_context_connect = &labsound_context_connect;
		exports_table.labsound_context_disconnect = &labsound_context_disconnect;
		exports_table.labsound_context_load_hrtf_database = &labsound_context_load_hrtf_database;
		exports_table.labsound_context_listener_set_forward = &labsound_context_listener_set_forward;
		exports_table.labsound_context_listener_set_up_vector = &labsound_context_listener_set_up_vector;
		exports_table.labsound_context_listener_set_position = &labsound_context_listener_set_position;
		exports_table.labsound_context_listener_set_velocity = &labsound_context_listener_set_velocity;
		exports_table.labsound_context_synchronize_connections = &labsound_context_synchronize_connections;

		// AudioDestinationNode
		exports_table.labsound_destination_node_create = &labsound_destination_node_create;
		exports_table.labsound_destination_node_destroy = &labsound_destination_node_destroy;

		// GainNode
		exports_table.labsound_gain_node_create = &labsound_gain_node_create;
		exports_table.labsound_gain_node_destroy = &labsound_gain_node_destroy;
		exports_table.labsound_gain_node_set_value = &labsound_gain_node_set_value;

		// PannerNode
		exports_table.labsound_panner_node_create = &labsound_panner_node_create;
		exports_table.labsound_panner_node_destroy = &labsound_panner_node_destroy;
		exports_table.labsound_panner_node_set_panning_model = &labsound_panner_node_set_panning_model;
		exports_table.labsound_panner_node_set_velocity = &labsound_panner_node_set_velocity;
		exports_table.labsound_panner_node_set_position = &labsound_panner_node_set_position;
		exports_table.labsound_panner_node_set_orientation = &labsound_panner_node_set_orientation;
		exports_table.labsound_panner_node_set_distance_model = &labsound_panner_node_set_distance_model;
		exports_table.labsound_panner_node_set_ref_distance = &labsound_panner_node_set_ref_distance;
		exports_table.labsound_panner_node_set_max_distance = &labsound_panner_node_set_max_distance;
		exports_table.labsound_panner_node_set_rolloff_factor = &labsound_panner_node_set_rolloff_factor;
		exports_table.labsound_panner_node_set_cone_inner_angle = &labsound_panner_node_set_cone_inner_angle;
		exports_table.labsound_panner_node_set_cone_outer_angle = &labsound_panner_node_set_cone_outer_angle;
		exports_table.labsound_panner_node_set_cone_outer_gain = &labsound_panner_node_set_cone_outer_gain;

		// SampledAudioNode
		exports_table.labsound_sampled_audio_node_from_file = &labsound_sampled_audio_node_from_file;
		exports_table.labsound_sampled_audio_node_from_memory = &labsound_sampled_audio_node_from_memory;
		exports_table.labsound_sampled_audio_node_destroy = &labsound_sampled_audio_node_destroy;
		exports_table.labsound_sampled_audio_node_start = &labsound_sampled_audio_node_start;
		exports_table.labsound_sampled_audio_node_stop = &labsound_sampled_audio_node_stop;

		exports_table.labsound_print_graph = &labsound_print_graph;
		exports_table.labsound_log_set_quiet = &log_set_quiet;

		return &exports_table;
	}

}