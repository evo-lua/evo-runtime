local ffi = require("ffi")
local jit = require("jit")
local labsound = require("labsound")
local transform = require("transform")

local isM1 = ffi.os == "OSX" and jit.arch == "arm64"
if isM1 then
	-- Can't feasibly remote-debug these, so skipping them is the only option (for now)
	print(transform.yellow("Skipping LabSound FFI HRTF test due to CoreAudio crashing in the M1 test runner"))
	return
end

math.randomseed(os.clock())

local WAV_FILE = path.join("deps", "LabSound", "LabSound", "assets", "samples", "trainrolling.wav")
local HRTF_DB_PATH = path.join("deps", "LabSound", "LabSound", "assets", "hrtf")

local numAudioDevices = tonumber(labsound.bindings.labsound_get_device_count())
assert(numAudioDevices > 0, "Cannot test audio playback without at least one available audio device")

local withInput = false
local defaultInputConfig = ffi.new("labsound_audio_stream_config_t")
local defaultOutputConfig = ffi.new("labsound_audio_stream_config_t")
assert(labsound.bindings.labsound_get_default_device_config(defaultInputConfig, defaultOutputConfig, withInput))

local audioDevice = labsound.bindings.labsound_device_create(defaultInputConfig, defaultOutputConfig)
local isOffline = false
local autoDispatchEvents = true
local audioContext = labsound.bindings.labsound_context_create(isOffline, autoDispatchEvents)
assert(audioContext ~= ffi.NULL, "Failed to create audio context")

local destinationNode = labsound.bindings.labsound_destination_node_create(audioContext, audioDevice)
assert(destinationNode ~= ffi.NULL, "Failed to create AudioDestinationNode")
local pannerNode = labsound.bindings.labsound_panner_node_create(audioContext)
assert(pannerNode ~= ffi.NULL, "Failed to create PannerNode")

labsound.bindings.labsound_panner_node_set_panning_model(pannerNode, ffi.C.LabSoundPanningModel_HRTF)

local mixToMono = false
local musicClipNode = labsound.bindings.labsound_sampled_audio_node_from_file(audioContext, WAV_FILE, mixToMono)

assert(musicClipNode ~= ffi.NULL, "Failed to create SampledAudioNode")
local inputSlotIndex, outputSlotIndex = 0, 0
assert(
	labsound.bindings.labsound_context_connect(audioContext, pannerNode, musicClipNode, inputSlotIndex, outputSlotIndex)
)
assert(
	labsound.bindings.labsound_context_connect(
		audioContext,
		destinationNode,
		pannerNode,
		inputSlotIndex,
		outputSlotIndex
	)
)

labsound.bindings.labsound_print_graph(destinationNode)
labsound.bindings.labsound_print_graph(pannerNode)
labsound.bindings.labsound_print_graph(musicClipNode)

local when, loopCount = 0, -1 -- A loop count of -1 means "forever", apparently...
assert(labsound.bindings.labsound_sampled_audio_node_start(musicClipNode, when, loopCount))

labsound.bindings.labsound_context_listener_set_position(audioContext, 0, 0, 0)
labsound.bindings.labsound_context_listener_set_forward(audioContext, 0, 0, 1)
labsound.bindings.labsound_context_listener_set_up_vector(audioContext, 0, 1, 0)
labsound.bindings.labsound_context_listener_set_velocity(audioContext, 0, 0, 0)
labsound.bindings.labsound_panner_node_set_velocity(pannerNode, 4, 0, 0)
labsound.bindings.labsound_context_synchronize_connections(audioContext)

local success = labsound.bindings.labsound_context_load_hrtf_database(audioContext, "does-not-exist")
assert(not success, "Should return true if trying to load an invalid spatialization database")
assert(labsound.bindings.labsound_context_load_hrtf_database(audioContext, HRTF_DB_PATH))

labsound.bindings.labsound_panner_node_set_distance_model(pannerNode, ffi.C.LabSoundDistanceModel_Linear)
labsound.bindings.labsound_panner_node_set_ref_distance(pannerNode, 1)
labsound.bindings.labsound_panner_node_set_max_distance(pannerNode, 10)
labsound.bindings.labsound_panner_node_set_rolloff_factor(pannerNode, 1)
labsound.bindings.labsound_panner_node_set_cone_inner_angle(pannerNode, 360)
labsound.bindings.labsound_panner_node_set_cone_outer_angle(pannerNode, 0)
labsound.bindings.labsound_panner_node_set_cone_outer_gain(pannerNode, 0)

local seconds = 15
local elapsedTimeInSeconds = 0

local radius = 1
local cx, cz = 0, 0

local positionUpdateTicker = C_Timer.NewTicker(10, function()
	local circularMotionAngle = (elapsedTimeInSeconds / seconds) * 2 * math.pi

	local sourcePositionX = cx + radius * math.cos(circularMotionAngle)
	local sourcePositionZ = cz + radius * math.sin(circularMotionAngle)

	-- Offset slightly to prevent the audio from abruptly switching sides
	local sourcePositionY = 0.1

	labsound.bindings.labsound_panner_node_set_position(pannerNode, sourcePositionX, sourcePositionY, sourcePositionZ)
	local dirX, dirY, dirZ = -sourcePositionX, -sourcePositionY, -sourcePositionZ

	local length = math.sqrt(dirX ^ 2 + dirY ^ 2 + dirZ ^ 2)
	local normalizedX, normalizedY, normalizedZ = dirX / length, dirY / length, dirZ / length
	labsound.bindings.labsound_panner_node_set_orientation(pannerNode, normalizedX, normalizedY, normalizedZ)

	elapsedTimeInSeconds = elapsedTimeInSeconds + 0.01
end)

C_Timer.After(seconds * 1000, function()
	print("LabSound FFI HRTF test complete; deleting the audio graph...")
	assert(labsound.bindings.labsound_sampled_audio_node_stop(musicClipNode, when))

	assert(
		labsound.bindings.labsound_context_disconnect(
			audioContext,
			pannerNode,
			musicClipNode,
			inputSlotIndex,
			outputSlotIndex
		)
	)
	assert(
		labsound.bindings.labsound_context_disconnect(
			audioContext,
			destinationNode,
			pannerNode,
			inputSlotIndex,
			outputSlotIndex
		)
	)
	C_Timer.After(1000, function()
		labsound.bindings.labsound_panner_node_destroy(pannerNode)
		labsound.bindings.labsound_sampled_audio_node_destroy(musicClipNode)
		labsound.bindings.labsound_destination_node_destroy(destinationNode)
		labsound.bindings.labsound_context_destroy(audioContext)
		labsound.bindings.labsound_device_destroy(audioDevice)
	end)
	positionUpdateTicker:stop()
end)
