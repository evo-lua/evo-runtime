local ffi = require("ffi")
local jit = require("jit")
local labsound = require("labsound")
local transform = require("transform")
local uv = require("uv")

local isM1 = ffi.os == "OSX" and jit.arch == "arm64"
if isM1 then
	-- Can't feasibly remote-debug these, so skipping them is the only option (for now)
	print(transform.yellow("Skipping LabSound FFI playback test due to CoreAudio crashing in the M1 test runner"))
	return
end

math.randomseed(os.clock())

local WAV_FILE = path.join("deps", "LabSound", "LabSound", "assets", "samples", "stereo-music-clip.wav")

local SILENCE_TRACE_LOG = (math.random(1, 100) > 50)
if SILENCE_TRACE_LOG then
	print("Disabling LabSound trace log")
	labsound.bindings.labsound_log_set_quiet(true)
else
	print("Enabling LabSound trace log")
	labsound.bindings.labsound_log_set_quiet(false)
end

local SIMULATE_ASYNC_IO = (math.random(1, 100) > 50)
if SIMULATE_ASYNC_IO then
	WAV_FILE = C_FileSystem.ReadFile(WAV_FILE)
end

local numAudioDevices = tonumber(labsound.bindings.labsound_get_device_count())
assert(numAudioDevices > 0, "Cannot test audio playback without at least one available audio device")

printf("Listing %d available audio devices...", numAudioDevices)
for deviceIndex = 0, numAudioDevices - 1, 1 do
	local deviceInfo = ffi.new("labsound_audio_device_info_t")
	assert(labsound.bindings.labsound_get_device_info(deviceIndex, deviceInfo))
	printf("\tDevice %d: %s", deviceInfo.index, ffi.string(deviceInfo.identifier))
	printf("\tNumber of input channels: %d", deviceInfo.num_input_channels)
	printf("\tNumber of output channels: %d", deviceInfo.num_output_channels)
	printf("\tDefault sample rate: %f", deviceInfo.nominal_samplerate)
	printf("\tIs default input: %s", deviceInfo.is_default_input and "true" or "false")
	printf("\tIs default output: %s", deviceInfo.is_default_output and "true" or "false")
end

local withInput = false
local defaultInputConfig = ffi.new("labsound_audio_stream_config_t")
local defaultOutputConfig = ffi.new("labsound_audio_stream_config_t")
assert(labsound.bindings.labsound_get_default_device_config(defaultInputConfig, defaultOutputConfig, withInput))

printf("Default input configuration:")
printf("\tDevice index: %d", defaultInputConfig.device_index)
printf("\tDesired number of channels: %d", defaultInputConfig.desired_channels)
printf("\tDesired sample rate: %d", defaultInputConfig.desired_samplerate)

printf("Default output configuration:")
printf("\tDevice index: %d", defaultOutputConfig.device_index)
printf("\tDesired number of channels: %d", defaultOutputConfig.desired_channels)
printf("\tDesired sample rate: %d", defaultOutputConfig.desired_samplerate)

local audioDevice = labsound.bindings.labsound_device_create(defaultInputConfig, defaultOutputConfig)
local isOffline = false
local autoDispatchEvents = true
local audioContext = labsound.bindings.labsound_context_create(isOffline, autoDispatchEvents)
assert(audioContext ~= ffi.NULL, "Failed to create audio context")

local destinationNode = labsound.bindings.labsound_destination_node_create(audioContext, audioDevice)
assert(destinationNode ~= ffi.NULL, "Failed to create AudioDestinationNode")

local gainNode = labsound.bindings.labsound_gain_node_create(audioContext)
assert(gainNode ~= ffi.NULL, "Failed to create GainNode")
local volumeGainPercentage = 0.25
assert(labsound.bindings.labsound_gain_node_set_value(gainNode, volumeGainPercentage))

local mixToMono = false
local musicClipNode
if SIMULATE_ASYNC_IO then
	printf("Creating SampledAudioNode from memory")
	musicClipNode =
		labsound.bindings.labsound_sampled_audio_node_from_memory(audioContext, WAV_FILE, #WAV_FILE, mixToMono)
else
	printf("Creating SampledAudioNode from file")
	musicClipNode = labsound.bindings.labsound_sampled_audio_node_from_file(audioContext, WAV_FILE, mixToMono)
end
assert(musicClipNode ~= ffi.NULL, "Failed to create SampledAudioNode")
local inputSlotIndex, outputSlotIndex = 0, 0
assert(
	labsound.bindings.labsound_context_connect(audioContext, gainNode, musicClipNode, inputSlotIndex, outputSlotIndex)
)
assert(
	labsound.bindings.labsound_context_connect(audioContext, destinationNode, gainNode, inputSlotIndex, outputSlotIndex)
)

labsound.bindings.labsound_print_graph(destinationNode)
labsound.bindings.labsound_print_graph(gainNode)
labsound.bindings.labsound_print_graph(musicClipNode)

local when, loopCount = 0, 0
assert(labsound.bindings.labsound_sampled_audio_node_start(musicClipNode, when, loopCount))

uv.sleep(3300)
printf("Stopping all nodes...")
assert(labsound.bindings.labsound_sampled_audio_node_stop(musicClipNode, when))

uv.sleep(1300)
printf("Disconnecting all nodes...")
assert(
	labsound.bindings.labsound_context_disconnect(
		audioContext,
		gainNode,
		musicClipNode,
		inputSlotIndex,
		outputSlotIndex
	)
)
assert(
	labsound.bindings.labsound_context_disconnect(
		audioContext,
		destinationNode,
		gainNode,
		inputSlotIndex,
		outputSlotIndex
	)
)

uv.sleep(1300)
printf("Reconnecting all nodes...")

assert(
	labsound.bindings.labsound_context_connect(audioContext, gainNode, musicClipNode, inputSlotIndex, outputSlotIndex)
)
assert(
	labsound.bindings.labsound_context_connect(audioContext, destinationNode, gainNode, inputSlotIndex, outputSlotIndex)
)

-- Playback doesn't automatically resume (see https://github.com/LabSound/LabSound/issues/199)
assert(labsound.bindings.labsound_sampled_audio_node_start(musicClipNode, when, loopCount))

uv.sleep(3300)
print("LabSound FFI playback test complete; deleting the audio graph...")
labsound.bindings.labsound_sampled_audio_node_destroy(musicClipNode)
labsound.bindings.labsound_gain_node_destroy(gainNode)
labsound.bindings.labsound_destination_node_destroy(destinationNode)
labsound.bindings.labsound_context_destroy(audioContext)
labsound.bindings.labsound_device_destroy(audioDevice)
