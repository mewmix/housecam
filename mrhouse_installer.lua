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
			-- Only list audio capable sources
			local flags = obs.obs_source_get_output_flags(source)
			if bit.band(flags, obs.OBS_SOURCE_AUDIO) ~= 0 then
				local name = obs.obs_source_get_name(source)
				obs.obs_property_list_add_string(p, name, name)
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

	-- 1. Create EQ (Telephone Effect)
	-- OBS Native 3-Band EQ
	create_filter(source, "MrHouse_EQ", "obs_3band_eq_filter", {
		high = -20.0, -- Cut treble
		mid = 2.0,    -- Boost mids slightly
		low = -20.0   -- Cut bass
	})

	-- 2. Create Distortion (Gain + Hard Clip)
	-- Step A: Boost Gain into the ceiling
	create_filter(source, "MrHouse_Drive", "gain_filter", {
		db = 20.0
	})
	-- Step B: Hard Limit to square it off (Distortion)
	create_filter(source, "MrHouse_Clip", "limiter_filter", {
		threshold = -20.0,
		release = 60
	})

	-- 3. Create Compressor (Consistency)
	create_filter(source, "MrHouse_Comp", "compressor_filter", {
		ratio = 10.0,
		threshold = -25.0,
		attack_time = 2,
		release_time = 100,
		output_gain = 0.0
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
