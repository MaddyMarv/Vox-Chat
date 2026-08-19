local mod = get_mod("VoxChat")
local Definitions = mod:io_dofile("VoxChat/scripts/mods/VoxChat/hud/hud_element_VoxChat_definitions")

local function utf8_sub(s, start_idx, end_idx)
    if not s or s == "" then return "" end
    local chars = {}
    for char in string.gmatch(s, "[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(chars, char)
    end
    local len = #chars
    if start_idx < 1 then start_idx = 1 end
    if end_idx > len then end_idx = len end
    if start_idx > end_idx then return "" end
    return table.concat(chars, "", start_idx, end_idx)
end

local function utf8_len(s)
    if not s or s == "" then return 0 end
    local count = 0
    for _ in string.gmatch(s, "[%z\1-\127\194-\244][\128-\191]*") do
        count = count + 1
    end
    return count
end

local PLAYER_COM_WHEEL_CONCEPT_FRAGMENTS = {
    "on_demand_com_wheel",
    "on_demand_vo_tag_enemy",
    "on_demand_vo_tag_item",
    "smart_tag",
    "tag_item",
    "tag_enemy",
    "look_at",
}

local PLAYER_COMBAT_CONCEPT_FRAGMENTS = {
    "combat_ability",
    "enemy_kill",
    "heard_enemy",
    "heard_horde",
    "higher_elite_threat",
    "interaction_vo",
    "knocked_down",
    "player_death",
    "player_enemy_alert",
    "seen_enemy_group_far_range_shooting_behind_cover",
    "seen_enemy",
    "seen_horde",
    "throwing_item",
    "throwing_net",
    "warning",
    "catching_net",
    "heal_start",
    "ledge_hanging",
    "pounced_by_special_attack",
    "rapid_loosing_health",
    "friends_close",
    "friends_distant",
    "heat_vo",
    "ranged_idle_player_out_of_ammo",
    "reload_failed",
    "reloading",
    "pinned_by_enemies",
}

local PLAYER_SOCIAL_CONCEPT_FRAGMENTS = {
    "confessional_vo",
    "enemy_near_death_monster",
    "environmental_story",
    "friendly_fire",
    "head_shot",
    "health_hog",
    "heard_speak",
    "kill_spree_self",
    "knocked_down_multiple_times",
    "multiple_head_pops",
    "player_tip_armor_hit",
    "short_story_talk",
    "start_banter",
    "story_talk",
    "combat_story_talk",
    "cutscene_vo_line",
    "ammo_hog",
    "seen_killstreak_",
}

local function _contains(value, fragment)
    return type(value) == "string" and type(fragment) == "string" and string.find(value, fragment, 1, true) ~= nil
end

local function _contains_any(value, fragments)
    if type(value) ~= "string" or value == "" or type(fragments) ~= "table" then
        return false
    end
    for i = 1, #fragments do
        if _contains(value, fragments[i]) then
            return true
        end
    end
    return false
end

local function _starts_with_any(value, prefixes)
    if type(value) ~= "string" or value == "" or type(prefixes) ~= "table" then
        return false
    end
    for i = 1, #prefixes do
        if string.find(value, prefixes[i], 1, true) == 1 then
            return true
        end
    end
    return false
end

local function _classify_explicit_player_concept(identifier)
    if _contains_any(identifier, PLAYER_COM_WHEEL_CONCEPT_FRAGMENTS) then return "com_wheel" end
    if _contains_any(identifier, PLAYER_SOCIAL_CONCEPT_FRAGMENTS) then return "social" end
    if _contains_any(identifier, PLAYER_COMBAT_CONCEPT_FRAGMENTS) then return "combat" end
    return nil
end

local function _is_player_explicit_social_event(identifier)
    if _contains(identifier, "conversation") then return true end
    if _contains(identifier, "bonding") then return true end
    if _contains(identifier, "reply") and not _contains(identifier, "no_reply") then return true end
    return false
end

local function _is_player_combat_event(identifier)
    if _starts_with_any(identifier, {
            "player_death", "team_downed", "player_ability", "player_kill", "player_horde",
            "player_throw", "team_warning", "team_hacking", "team_monster", "player_blitz",
            "seen_netgunner", "seen_enemy_",
        }) then
        return true
    end

    if _contains_any(identifier, {
            "ability", "blitz", "throwing_grenade", "enemy_daemonhost", "event_scan",
            "luggable", "warning_exploding_barrel", "critical_health", "response_to_hacking_fix_decode",
            "hacking_fix_decode", "monster_fight_start_reaction", "disabled_by_enemy", "need_rescue",
            "disabled_by_chaos_hound", "response_for_pinned_by_enemies", "_kill",
        }) then
        return true
    end

    return false
end

local function _is_banter(dialogue)
	local identifier = dialogue.concept or dialogue.dialogue_name or dialogue.dialogue_event_name or dialogue.currently_playing_subtitle or dialogue.category or dialogue.sound_event
	if not identifier or type(identifier) ~= "string" then return false end
	
    local explicit = _classify_explicit_player_concept(identifier)
    if explicit == "social" then return true end
    if explicit == "com_wheel" or explicit == "combat" then return false end
    
    if _contains(identifier, "com_wheel_vo") then return false end
    if _is_player_explicit_social_event(identifier) then return true end
    if _is_player_combat_event(identifier) then return false end
    
    return true
end

local HudElementPlayerVoicePopup = class("HudElementPlayerVoicePopup", "HudElementBase")

HudElementPlayerVoicePopup.init = function (self, parent, draw_layer, start_scale)
	HudElementPlayerVoicePopup.super.init(self, parent, draw_layer, start_scale, Definitions)

	local num_bars = Definitions.bar_amount
	local bar_offset = Definitions.bar_offset
	local bar_size = Definitions.bar_size
	local bar_spacing = Definitions.bar_spacing
	local bar_widgets = {}

	for i = 1, num_bars do
		local name = "bar_" .. i
		local widget = self._widgets_by_name[name]

		widget.offset = {
			bar_offset[1] + (bar_size[1] + bar_spacing) * (i - 1),
			bar_offset[2],
			bar_offset[3],
		}
		bar_widgets[i] = widget
	end

	self._bar_widgets = bar_widgets
	self._is_speaking = false
	self._speaker_account_id = nil
	self._portrait_loaded_info = nil
	self._active_speakers = {}
	self._voip_speakers = {}
	self._dialogue_speakers = {}
	self._participant_cache = {}

	self:_update_alignment()

	Managers.event:register(self, "chat_manager_participant_update", "_chat_manager_participant_update")
	Managers.event:register(self, "chat_manager_participant_removed", "_chat_manager_participant_removed")
end

HudElementPlayerVoicePopup.destroy = function (self, ui_renderer)
	Managers.event:unregister(self, "chat_manager_participant_update")
	Managers.event:unregister(self, "chat_manager_participant_removed")
	self:_unload_portrait_icon()
	HudElementPlayerVoicePopup.super.destroy(self, ui_renderer)
end

HudElementPlayerVoicePopup._update_active_speaker = function(self)
	local top_speaker = self._active_speakers[#self._active_speakers]

	if top_speaker ~= self._speaker_account_id then
		if not top_speaker then
			self:_mission_speaker_stop()
			self._speaker_account_id = nil
			self._is_speaking = false
		else
			self._speaker_account_id = top_speaker
			self._is_speaking = true

			local player
			local players = Managers.player:players()
			for _, p in pairs(players) do
				if p:account_id() == top_speaker then
					player = p
					break
				end
			end

			local profile
			local name
			local player_info

			if player then
				profile = player:profile()
				name = player:name()
				if player:is_human_controlled() then
					player_info = Managers.data_service.social:_get_player_info_for_player(player)
				end
			end

			if not name or name == "" or not player_info then
				local info = Managers.data_service.social:get_player_info_by_account_id(top_speaker)
				if info then
					name = name or info:character_name()
					if not name or name == "" then
						name = info:user_display_name()
					end
					profile = profile or info:profile()
					player_info = player_info or info
				end
			end

			local fallback_name = "Unknown"
			local cached_participant = self._participant_cache[top_speaker]
			if cached_participant then
				fallback_name = cached_participant.character_name or cached_participant.account_name or "Unknown"
			end
			name = name or fallback_name
			local subtitle_id = self._in_game_subtitles and self._in_game_subtitles[top_speaker]
			self:_mission_speaker_start(name, profile, player_info, subtitle_id)
		end
	end
end

HudElementPlayerVoicePopup._chat_manager_participant_update = function (self, channel_handle, participant)
	local is_speaking = participant.is_speaking
	local account_id = participant.account_id

	if is_speaking then
		if not table.find(self._voip_speakers, account_id) then
			table.insert(self._voip_speakers, account_id)
		end
	else
		local index = table.find(self._voip_speakers, account_id)
		if index then
			table.remove(self._voip_speakers, index)
		end
	end

	self._participant_cache[account_id] = participant
end

HudElementPlayerVoicePopup._chat_manager_participant_removed = function (self, channel_handle, participant_uri, participant)
	local account_id = participant and participant.account_id
	if account_id then
		local index = table.find(self._voip_speakers, account_id)
		if index then
			table.remove(self._voip_speakers, index)
		end
	end
end

HudElementPlayerVoicePopup.update = function (self, dt, t, ui_renderer, render_settings, input_service)
	HudElementPlayerVoicePopup.super.update(self, dt, t, ui_renderer, render_settings, input_service)

	local current_speakers = {}
	self._in_game_subtitles = {}

	local dialogue_speakers = {}
	local voip_speakers = {}

	local local_player = Managers.player:local_player(1)
	local local_player_id = local_player and local_player:account_id()

	if mod:get("in_game_dialogue") then
		local dialogue_system = Managers.state.extension and Managers.state.extension:system("dialogue_system")
		if dialogue_system and dialogue_system.playing_dialogues_array then
			local playing_dialogues = dialogue_system:playing_dialogues_array()
			local local_pos = local_player and local_player.player_unit and Unit.alive(local_player.player_unit) and Unit.world_position(local_player.player_unit, 1)
			local distance_threshold = mod:get("vox_distance") or 15

			local current_active_dialogues = {}

			for i = 1, #playing_dialogues do
				local dialogue = playing_dialogues[i]
				local unit = dialogue.currently_playing_unit
				if unit and Unit.alive(unit) then
					local is_far_enough = true
					if local_pos then
						local speaker_pos = Unit.world_position(unit, 1)
						local distance = Vector3.distance(local_pos, speaker_pos)
						if distance < distance_threshold then
							is_far_enough = false
						end
					end

					local is_local = (local_player and unit == local_player.player_unit)
					local should_add = false

					if is_local then
						should_add = mod:get("show_self_dialogue") ~= false
					else
						should_add = is_far_enough
					end

					if should_add then
						local player_unit_spawn_manager = Managers.state.player_unit_spawn
						local player = player_unit_spawn_manager and player_unit_spawn_manager:owner(unit)
						if player then
							local filter_mode = mod:get("dialogue_filter_mode") or "all"
							if filter_mode == "combat_only" and _is_banter(dialogue) then
								should_add = false
							elseif filter_mode == "banter_only" and not _is_banter(dialogue) then
								should_add = false
							end

							if should_add then
								local account_id = player:account_id()
								if account_id and not table.find(current_active_dialogues, account_id) then
									table.insert(current_active_dialogues, account_id)
								end
								if account_id then
									self._in_game_subtitles[account_id] = dialogue.currently_playing_subtitle
								end
							end
						end
					end
				end
			end
			
			for i = 1, #current_active_dialogues do
				local id = current_active_dialogues[i]
				if not table.find(self._dialogue_speakers, id) then
					table.insert(self._dialogue_speakers, id)
				end
			end
			
			for i = #self._dialogue_speakers, 1, -1 do
				local id = self._dialogue_speakers[i]
				if not table.find(current_active_dialogues, id) then
					table.remove(self._dialogue_speakers, i)
				end
			end
			
			dialogue_speakers = table.clone(self._dialogue_speakers)
		end
	end

	if mod:get("enable_voip") ~= false then
		local show_self_voip = mod:get("show_self") ~= false
		local voip_distance_threshold = mod:get("voip_distance") or 0
		local local_pos = local_player and local_player.player_unit and Unit.alive(local_player.player_unit) and Unit.world_position(local_player.player_unit, 1)

		for i = 1, #self._voip_speakers do
			local account_id = self._voip_speakers[i]
			local is_local = (local_player_id and account_id == local_player_id)
			
			local should_add = false

			if is_local then
				should_add = show_self_voip
			else
				local is_far_enough = true
				if local_pos and voip_distance_threshold > 0 then
					local players = Managers.player:players()
					local speaker_player
					for _, p in pairs(players) do
						if p:account_id() == account_id then
							speaker_player = p
							break
						end
					end

					if speaker_player and speaker_player.player_unit and Unit.alive(speaker_player.player_unit) then
						local speaker_pos = Unit.world_position(speaker_player.player_unit, 1)
						local distance = Vector3.distance(local_pos, speaker_pos)
						if distance < voip_distance_threshold then
							is_far_enough = false
						end
					end
				end
				should_add = is_far_enough
			end
			
			if should_add then
				if not table.find(voip_speakers, account_id) then
					table.insert(voip_speakers, account_id)
				end
			end
		end
	end

	local function append_speakers(target_list, source_list)
		for i = 1, #source_list do
			local account_id = source_list[i]
			local existing_index = table.find(target_list, account_id)
			if existing_index then
				table.remove(target_list, existing_index)
			end
			table.insert(target_list, account_id)
		end
	end

	if mod:get("voip_priority") then
		append_speakers(current_speakers, dialogue_speakers)
		append_speakers(current_speakers, voip_speakers)
	else
		append_speakers(current_speakers, voip_speakers)
		append_speakers(current_speakers, dialogue_speakers)
	end

	if mod:get("mission_only") then
		local game_mode_name = Managers.state.game_mode and Managers.state.game_mode:game_mode_name()
		if game_mode_name == "hub" or game_mode_name == "prologue_hub" then
			table.clear(current_speakers)
		end
	end

	self._active_speakers = current_speakers
	local top_speaker = current_speakers[#current_speakers]
	if top_speaker ~= self._speaker_account_id then
		self:_update_active_speaker()
	end
	
	if top_speaker then
		local new_subtitle = self._in_game_subtitles[top_speaker]
		if self._current_subtitle_id ~= new_subtitle then
			self._current_subtitle_id = new_subtitle
			local text = ""
			if new_subtitle and mod:get("show_subtitles") ~= false then
				text = Localize(new_subtitle)
			end
			self._full_subtitle_text = text
			self._subtitle_scroll_index = 1
			self._subtitle_scroll_timer = 0
			self._widgets_by_name.subtitle_text.content.subtitle_text = text
		end
	else
		if self._current_subtitle_id ~= nil then
			self._current_subtitle_id = nil
			self._full_subtitle_text = nil
			self._widgets_by_name.subtitle_text.content.subtitle_text = ""
		end
	end

	if self._full_subtitle_text and self._full_subtitle_text ~= "" then
		if mod:get("scroll_subtitles") ~= false then
			local text = self._full_subtitle_text
			local total_len = utf8_len(text)
			local scroll_len = mod:get("scroll_subtitles_length") or 40
			
			if total_len > scroll_len then
				local speed = mod:get("scroll_subtitles_speed") or 0.2
				self._subtitle_scroll_timer = (self._subtitle_scroll_timer or 0) + dt
				if self._subtitle_scroll_timer >= speed then
					self._subtitle_scroll_timer = self._subtitle_scroll_timer - speed
					self._subtitle_scroll_index = (self._subtitle_scroll_index or 1) + 1
					
					if self._subtitle_scroll_index > total_len then
						self._subtitle_scroll_index = 1
					end
				end
				
				local padded_text = text .. "          " .. text
				local display_text = utf8_sub(padded_text, self._subtitle_scroll_index, self._subtitle_scroll_index + scroll_len - 1)
				self._widgets_by_name.subtitle_text.content.subtitle_text = display_text
			else
				self._widgets_by_name.subtitle_text.content.subtitle_text = self._full_subtitle_text
			end
		else
			self._widgets_by_name.subtitle_text.content.subtitle_text = self._full_subtitle_text
		end
	end

	if self._is_speaking then
		self._incoming_dots_timer = (self._incoming_dots_timer or 0) + dt
		if self._incoming_dots_timer >= 0.5 then
			self._incoming_dots_timer = 0
			self._incoming_dots_count = ((self._incoming_dots_count or 0) + 1) % 4
			local dots = string.rep(".", self._incoming_dots_count)
			
			local base_text = self._is_dialogue_speaker and "INCOMING" or "VOICE COMM - INCOMING"
			self._widgets_by_name.title_text.content.title_text = base_text .. dots
		end
	end

	local current_subtitle_offset_x = mod:get("subtitle_offset_x") or 0
	local current_subtitle_offset_y = mod:get("subtitle_offset_y") or 95
	local current_subtitle_font_size = mod:get("subtitle_font_size") or 24
	local subtitle_color = mod:get("subtitle_color") or { 255, 241, 231, 163 }
	local color_r = subtitle_color[2]
	local color_g = subtitle_color[3]
	local color_b = subtitle_color[4]
	local color_a = subtitle_color[1]

	if mod:get("alignment") ~= self._current_alignment
		or current_subtitle_offset_x ~= self._current_subtitle_offset_x
		or current_subtitle_offset_y ~= self._current_subtitle_offset_y
		or current_subtitle_font_size ~= self._current_subtitle_font_size
		or color_r ~= self._color_r
		or color_g ~= self._color_g
		or color_b ~= self._color_b
		or color_a ~= self._color_a then
		
		self:_update_alignment()
		
		self._current_subtitle_offset_x = current_subtitle_offset_x
		self._current_subtitle_offset_y = current_subtitle_offset_y
		self._current_subtitle_font_size = current_subtitle_font_size
		self._color_r = color_r
		self._color_g = color_g
		self._color_b = color_b
		self._color_a = color_a
	end

	if self._popup_animation_id and not self:_is_animation_active(self._popup_animation_id) then
		self._popup_animation_id = nil
	end

	local bar_timer = self._bar_timer or 0

	if bar_timer <= 0 then
		self:_update_bar_value(dt)
		bar_timer = 0.1
	else
		bar_timer = bar_timer - dt
	end

	self._bar_timer = bar_timer

	if self._is_speaking then
		local widget = self._widgets_by_name.popup
		if widget and widget.style.portrait and widget.style.portrait.material == "content/ui/materials/base/ui_radio_portrait_base" and widget.style.portrait.material_values then
			local anim_progress = math.min((1 + math.sin(Application.time_since_launch() * 6) * 0.5) * math.random_range(0.3, 0.8), 1)
			widget.style.portrait.material_values.distortion = 0.8 + (anim_progress * 0.4)
			widget.dirty = true
		end
	end
	
	local subtitle_widget = self._widgets_by_name.subtitle_text
	if subtitle_widget and self._is_speaking then
		local subtitle_text = subtitle_widget.content.subtitle_text
		if subtitle_text and subtitle_text ~= "" then
			local style = subtitle_widget.style.subtitle_text
			local is_left = self._current_alignment == "left"
			local sub_offset_x = self._current_subtitle_offset_x or 0
			style.offset[1] = (is_left and sub_offset_x or -sub_offset_x)
		end
	end
end

HudElementPlayerVoicePopup._update_bar_value = function (self, dt)
	local bar_widgets = self._bar_widgets
	local num_bars = #bar_widgets
	local next_bar_index = math.index_wrapper((self._previous_bar_index or 0) + 1, num_bars)
	local anim_progress = math.min((1 + math.sin(Application.time_since_launch() * 6) * 0.5) * math.random_range(0.3, 0.8), 1)
	local bar_size = Definitions.bar_size
	local bar_height = bar_size[2]

	for i = num_bars, 1, -1 do
		local new_bar_height

		if i > 1 then
			new_bar_height = bar_widgets[i - 1].style.bar.size[2]
		else
			new_bar_height = bar_height * anim_progress
		end

		local widget = bar_widgets[i]
		widget.style.bar.size[2] = new_bar_height
	end

	self._previous_bar_index = next_bar_index
end

HudElementPlayerVoicePopup._mission_speaker_stop = function (self)
	if self._popup_animation_id then
		self:_stop_animation(self._popup_animation_id)
		self._popup_animation_id = nil
	end

	local popup_animation_id = self:_start_animation("popup_exit", self._widgets_by_name)
	self._popup_animation_id = popup_animation_id
end

HudElementPlayerVoicePopup._mission_speaker_start = function (self, name_text, profile, player_info, subtitle_id)
	if self._popup_animation_id then
		self:_stop_animation(self._popup_animation_id)
		self._popup_animation_id = nil
	end

	local widgets_by_name = self._widgets_by_name
	widgets_by_name.name_text.content.name_text = name_text
	
	self._is_dialogue_speaker = (subtitle_id ~= nil)
	self._incoming_dots_timer = 0
	self._incoming_dots_count = 0
	
	if self._is_dialogue_speaker then
		widgets_by_name.title_text.content.title_text = "INCOMING"
	else
		widgets_by_name.title_text.content.title_text = "VOICE COMM - INCOMING"
	end
	
	if subtitle_id and mod:get("show_subtitles") ~= false then
		widgets_by_name.subtitle_text.content.subtitle_text = Localize(subtitle_id)
	else
		widgets_by_name.subtitle_text.content.subtitle_text = ""
	end

	local style = mod:get("portrait_style") or "pfp"
	local pfp_mod = get_mod("ProfilePictures")

	local portrait_rendering_enabled = true
	local save_manager = Managers.save
	if save_manager then
		local account_data = save_manager:account_data()
		if account_data and account_data.interface_settings then
			local setting = account_data.interface_settings.portrait_rendering_enabled
			if setting ~= nil then
				portrait_rendering_enabled = setting
			end
		end
	end

	local load_3d = ((style == "3d" or style == "pfp") and portrait_rendering_enabled and profile)

	self:_unload_portrait_icon()

	widgets_by_name.popup.content.portrait = "content/ui/materials/base/ui_radio_portrait_base"
	widgets_by_name.popup.style.portrait.material = "content/ui/materials/base/ui_radio_portrait_base"
	if widgets_by_name.popup.style.portrait.material_values then
		widgets_by_name.popup.style.portrait.material_values.distortion = 1
	end

	if load_3d then
		self:_load_portrait_icon(profile, player_info)
	end

	if profile then
		self:_load_portrait_frame(profile)
	else
		self:_unload_portrait_frame()
	end

	local current_account_id = self._speaker_account_id
	if style == "pfp" and pfp_mod and player_info then
		pfp_mod.load_profile_image(player_info, function(texture)
			if self._speaker_account_id ~= current_account_id then
				return
			end
			local widget = self._widgets_by_name.popup
			if widget then
				local portrait_style = widget.style.profile
				if portrait_style then
					portrait_style.material_values.texture_map = texture
					widget.content.use_pfp_frame = true
					
					widget.content.portrait = "content/ui/materials/base/ui_portrait_frame_base_no_render"
					widget.style.portrait.material = "content/ui/materials/base/ui_portrait_frame_base_no_render"
					if widget.style.portrait.material_values then
						widget.style.portrait.material_values.distortion = 0
					end
					
					widget.dirty = true
				end
			end
		end)
	end

	local popup_animation_id = self:_start_animation("popup_enter", self._widgets_by_name)
	self._popup_animation_id = popup_animation_id
end

HudElementPlayerVoicePopup._load_portrait_icon = function (self, profile, player_info)
	self:_unload_portrait_icon()

	local load_cb = callback(self, "_cb_set_player_icon", profile)
	local unload_cb = callback(self, "_cb_unset_player_icon")
	local icon_load_id = Managers.ui:load_profile_portrait(profile, load_cb, nil, unload_cb)

	self._portrait_loaded_info = {
		icon_load_id = icon_load_id,
		character_id = profile.character_id,
	}
end

HudElementPlayerVoicePopup._load_portrait_frame = function (self, profile)
	self:_unload_portrait_frame()

	local frame_item = profile.loadout and profile.loadout.portrait_frame
	if not frame_item then
		return
	end

	local cb = callback(self, "_cb_set_player_frame")
	local icon_load_id = Managers.ui:load_item_icon(frame_item, cb)

	self._frame_loaded_info = {
		icon_load_id = icon_load_id,
	}
end

HudElementPlayerVoicePopup._unload_portrait_frame = function (self)
	local frame_loaded_info = self._frame_loaded_info
	if not frame_loaded_info then
		return
	end

	local icon_load_id = frame_loaded_info.icon_load_id
	Managers.ui:unload_item_icon(icon_load_id)
	self._frame_loaded_info = nil

	local widget = self._widgets_by_name.popup
	if widget and widget.style.pfp_frame then
		widget.style.pfp_frame.material_values.texture_map = "content/ui/textures/nameplates/portrait_frames/default"
		widget.dirty = true
	end
end

HudElementPlayerVoicePopup._cb_set_player_frame = function (self, item)
	if self.__deleted then
		return
	end

	local widget = self._widgets_by_name.popup
	if widget and widget.style.pfp_frame then
		local icon = item.icon or "content/ui/textures/nameplates/portrait_frames/default"
		widget.style.pfp_frame.material_values.texture_map = icon
		widget.dirty = true
	end
end

HudElementPlayerVoicePopup._unload_portrait_icon = function (self)
	local widget = self._widgets_by_name.popup
	if widget and widget.style.profile then
		widget.style.profile.material_values.texture_map = nil
		widget.content.use_pfp_frame = false
		widget.dirty = true
	end

	local portrait_loaded_info = self._portrait_loaded_info
	if not portrait_loaded_info then
		return
	end

	local icon_load_id = portrait_loaded_info.icon_load_id
	Managers.ui:unload_profile_portrait(icon_load_id)
	self._portrait_loaded_info = nil
end

HudElementPlayerVoicePopup._cb_set_player_icon = function (self, profile, grid_index, rows, columns, render_target)
	local widget = self._widgets_by_name.popup
	local material_values = widget.style.portrait.material_values

	if not widget.content.use_pfp_frame then
		widget.style.portrait.material = "content/ui/materials/base/ui_portrait_frame_base"
		widget.content.portrait = "content/ui/materials/base/ui_portrait_frame_base"
	end

	material_values.use_placeholder_texture = 0
	material_values.rows = rows
	material_values.columns = columns
	material_values.grid_index = grid_index - 1
	material_values.texture_icon = render_target

	widget.dirty = true
end

HudElementPlayerVoicePopup._cb_unset_player_icon = function (self)
	local widget = self._widgets_by_name.popup
	local material_values = widget.style.portrait.material_values

	material_values.use_placeholder_texture = nil
	material_values.rows = nil
	material_values.columns = nil
	material_values.grid_index = nil
	material_values.texture_icon = nil

    widget.content.portrait = "content/ui/materials/base/ui_portrait_frame_base_no_render"
	widget.style.portrait.material = "content/ui/materials/base/ui_portrait_frame_base_no_render"

	widget.dirty = true
end

HudElementPlayerVoicePopup._draw_widgets = function (self, dt, t, input_service, ui_renderer, render_settings)
	if not self._popup_animation_id and not self._is_speaking then
		return
	end

	HudElementPlayerVoicePopup.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)
end

HudElementPlayerVoicePopup._update_alignment = function(self)
	local alignment = mod:get("alignment") or "left"
	self._current_alignment = alignment

	local is_left = alignment == "left"

	local ui_scenegraph = self._ui_scenegraph
	if ui_scenegraph and ui_scenegraph.background then
		ui_scenegraph.background.horizontal_alignment = alignment
		ui_scenegraph.background.position[1] = is_left and 50 or -50
	end

	local name_text = self._widgets_by_name.name_text
	if name_text then
		name_text.style.name_text.horizontal_alignment = alignment
		name_text.style.name_text.text_horizontal_alignment = alignment
		name_text.style.name_text.offset[1] = is_left and (Definitions.portrait_size[1] + 20) or -(Definitions.portrait_size[1] + 20)
	end

	local title_text = self._widgets_by_name.title_text
	if title_text then
		title_text.style.title_text.horizontal_alignment = alignment
		title_text.style.title_text.text_horizontal_alignment = alignment
		title_text.style.title_text.offset[1] = is_left and (Definitions.portrait_size[1] + 20) or -(Definitions.portrait_size[1] + 20)
	end

	local subtitle_text = self._widgets_by_name.subtitle_text
	if subtitle_text then
		local sub_offset_x = mod:get("subtitle_offset_x") or 0
		local sub_offset_y = mod:get("subtitle_offset_y") or 95
		local sub_font_size = mod:get("subtitle_font_size") or 24
		
		local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
		local color_table = mod:get("subtitle_color") or { 255, 241, 231, 163 }

		local base_x = 0
		subtitle_text.style.subtitle_text.horizontal_alignment = alignment
		subtitle_text.style.subtitle_text.text_horizontal_alignment = alignment
		subtitle_text.style.subtitle_text.offset[1] = base_x + (is_left and sub_offset_x or -sub_offset_x)
		subtitle_text.style.subtitle_text.offset[2] = sub_offset_y
		subtitle_text.style.subtitle_text.font_size = sub_font_size
		subtitle_text.style.subtitle_text.text_color = color_table
	end

	local radio = self._widgets_by_name.radio
	if radio then
		radio.style.soundwave.horizontal_alignment = alignment
		radio.style.soundwave.offset[1] = is_left and 265 or -265
	end

	local bar_offset_x = Definitions.bar_offset[1]
	for i = 1, Definitions.bar_amount do
		local name = "bar_" .. i
		local widget = self._widgets_by_name[name]
		if widget then
			widget.style.background.horizontal_alignment = alignment
			widget.style.bar.horizontal_alignment = alignment
			widget.style.frame.horizontal_alignment = alignment
			
			widget.style.frame.offset[1] = is_left and -2 or 2
			
			local x_pos = bar_offset_x + (Definitions.bar_size[1] + Definitions.bar_spacing) * (i - 1)
			widget.offset[1] = is_left and x_pos or -x_pos
		end
	end
end

return HudElementPlayerVoicePopup
