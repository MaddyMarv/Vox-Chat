local mod = get_mod("VoxChat")
local Definitions = mod:io_dofile("VoxChat/scripts/mods/VoxChat/hud_element_VoxChat_definitions")
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

HudElementPlayerVoicePopup._update_active_speaker = function(self, triggering_participant)
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

			local fallback_name = (triggering_participant and triggering_participant.account_id == top_speaker) and (triggering_participant.character_name or triggering_participant.account_name) or "Unknown"
			name = name or fallback_name

			self:_mission_speaker_start(name, profile, player_info)
		end
	end
end

HudElementPlayerVoicePopup._chat_manager_participant_update = function (self, channel_handle, participant)
	local is_speaking = participant.is_speaking
	local account_id = participant.account_id

	local local_player_id = Managers.player:local_player(1):account_id()

	if account_id == local_player_id and not mod:get("show_self") then
		return
	end

	if mod:get("mission_only") then
		local game_mode_name = Managers.state.game_mode and Managers.state.game_mode:game_mode_name()
		if game_mode_name == "hub" or game_mode_name == "prologue_hub" then
			return
		end
	end

	local index = table.find(self._active_speakers, account_id)

	if is_speaking then
		if not index then
			table.insert(self._active_speakers, account_id)
		end
	else
		if index then
			table.remove(self._active_speakers, index)
		end
	end

	self:_update_active_speaker(participant)
end

HudElementPlayerVoicePopup._chat_manager_participant_removed = function (self, channel_handle, participant_uri, participant)
	local account_id = participant and participant.account_id
	if account_id then
		local index = table.find(self._active_speakers, account_id)
		if index then
			table.remove(self._active_speakers, index)
			self:_update_active_speaker(nil)
		end
	end
end

HudElementPlayerVoicePopup.update = function (self, dt, t, ui_renderer, render_settings, input_service)
	HudElementPlayerVoicePopup.super.update(self, dt, t, ui_renderer, render_settings, input_service)

	if mod:get("alignment") ~= self._current_alignment then
		self:_update_alignment()
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

	if self._is_speaking and (mod:get("portrait_style") or "pfp") == "tv" then
		local widget = self._widgets_by_name.popup
		if widget and widget.style.portrait and widget.style.portrait.material_values then
			local anim_progress = math.min((1 + math.sin(Application.time_since_launch() * 6) * 0.5) * math.random_range(0.3, 0.8), 1)
			widget.style.portrait.material_values.distortion = 0.8 + (anim_progress * 0.4)
			widget.dirty = true
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

HudElementPlayerVoicePopup._mission_speaker_start = function (self, name_text, profile, player_info)
	if self._popup_animation_id then
		self:_stop_animation(self._popup_animation_id)
		self._popup_animation_id = nil
	end

	local widgets_by_name = self._widgets_by_name
	widgets_by_name.name_text.content.name_text = name_text

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

	local load_3d = (style == "3d" and portrait_rendering_enabled and profile)

	if load_3d then
		self:_load_portrait_icon(profile, player_info)
	else
		self:_unload_portrait_icon()
		widgets_by_name.popup.content.portrait = "content/ui/materials/base/ui_radio_portrait_base"
		widgets_by_name.popup.style.portrait.material = "content/ui/materials/base/ui_radio_portrait_base"
		if widgets_by_name.popup.style.portrait.material_values then
			widgets_by_name.popup.style.portrait.material_values.distortion = 1
		end
	end

	if profile then
		self:_load_portrait_frame(profile)
	else
		self:_unload_portrait_frame()
	end

	if style == "pfp" and pfp_mod and player_info then
		pfp_mod.load_profile_image(player_info, function(texture)
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

	-- To match player_panel_base, we change the material to ui_portrait_frame_base
	widget.style.portrait.material = "content/ui/materials/base/ui_portrait_frame_base"
	widget.content.portrait = "content/ui/materials/base/ui_portrait_frame_base"

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
