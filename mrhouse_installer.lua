obs = obslua

source_name = ""

-- Script description displayed in OBS
function script_description()
	return [[
Mr. House Audio Intercom Installer
----------------------------------
Automatically adds a native filter chain to your microphone to simulate the Fallout: New Vegas "Mr. House" intercom voice.

Effect Chain:
1. EQ (Telephone Bandpass)
2. Distortion (Gain + Hard Limiter)
3. Compression (Broadcast consistency)

Instructions:
1. Select your microphone source below.
2. Click "Apply Mr. House Effect".
]]
end

-- Script properties (UI)
function script_properties()
	local props = obs.obs_properties_create()
	
	local p = obs.obs_properties_add_list(props, "source", "Audio Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local sources = obs.obs_enum_sources()
	if sources ~= nil then
		for _, source in ipairs(sources) do
			local source_id = obs.obs_source_get_id(source)
			-- Only list audio capable sources that are INPUTS (e.g. Mics, Media Files)
			-- This excludes Scenes, Groups, and Transitions
			local type = obs.obs_source_get_type(source)
			if type == obs.OBS_SOURCE_TYPE_INPUT then
				local flags = obs.obs_source_get_output_flags(source)
				if bit.band(flags, obs.OBS_SOURCE_AUDIO) ~= 0 then
					local name = obs.obs_source_get_name(source)
					obs.obs_property_list_add_string(p, name, name)
				end
			end
		end
	end
	obs.source_list_release(sources)

	obs.obs_properties_add_button(props, "apply_button", "Apply Mr. House Effect", apply_effect)
	
	return props
end

-- Update variable when property changes
function script_update(settings)
	source_name = obs.obs_data_get_string(settings, "source")
end

-- Main logic: Apply filters
function apply_effect(props, p)
	local source = obs.obs_get_source_by_name(source_name)
	if source == nil then
		return
	end

	-- 1. Noise Gate (Intercom Squelch)
	-- Cuts silence abruptly to sound like PTT (Push-To-Talk)
	create_filter(source, "MrHouse_Gate", "noise_gate_filter", {
		open_threshold = -26.0,
		close_threshold = -32.0,
		attack_time = 10,
		hold_time = 50,
		release_time = 50
	})

	-- 2. Stacked EQ (Steeper Telephone Effect)
	-- Native EQ is gentle, so we stack TWO of them to cut frequencies harder (-40dB total)
	create_filter(source, "MrHouse_EQ_1", "obs_3band_eq_filter", {
		high = -20.0, mid = 3.0, low = -20.0
	})
	create_filter(source, "MrHouse_EQ_2", "obs_3band_eq_filter", {
		high = -20.0, mid = 2.0, low = -20.0
	})

	-- 3. Distortion (Harder Drive)
	create_filter(source, "MrHouse_Drive", "gain_filter", {
		db = 25.0 -- Pushed harder for more crunch
	})
	create_filter(source, "MrHouse_Clip", "limiter_filter", {
		threshold = -25.0,
		release = 50
	})

	-- 4. Compressor (Broadcast consistency)
	create_filter(source, "MrHouse_Comp", "compressor_filter", {
		ratio = 15.0, -- Higher ratio
		threshold = -30.0,
		attack_time = 2,
		release_time = 100,
		output_gain = 2.0
	})

	obs.obs_source_release(source)
	return true
end

-- Helper to create and configure a filter
function create_filter(source, name, id, settings_table)
	local settings = obs.obs_data_create()
	
	for k, v in pairs(settings_table) do
		if type(v) == "number" then
			obs.obs_data_set_double(settings, k, v)
		elseif type(v) == "string" then
			obs.obs_data_set_string(settings, k, v)
		elseif type(v) == "boolean" then
			obs.obs_data_set_bool(settings, k, v)
		end
	end

	local filter = obs.obs_source_create_private(id, name, settings)
	obs.obs_source_filter_add(source, filter)
	
	obs.obs_source_release(filter)
	obs.obs_data_release(settings)
end
