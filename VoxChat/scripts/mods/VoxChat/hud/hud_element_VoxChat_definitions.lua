local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")

local mod = get_mod("VoxChat")
local hud_scale = mod and mod:get("hud_scale") or 1.0

local portrait_size = { 80 * hud_scale, 90 * hud_scale }
local bar_amount = 7
local bar_size = { 12 * hud_scale, 30 * hud_scale }

local MAX_SLOTS = 4
local slot_spacing_y = 140 * hud_scale

local scenegraph_definition = {
	screen = UIWorkspaceSettings.screen,
}

local default_positions = {
	{ 50, 300 },
	{ 50, 440 },
	{ 50, 580 },
	{ 50, 720 },
}

for i = 1, MAX_SLOTS do
	local slot_x = mod and mod:get("slot_" .. i .. "_x") or default_positions[i][1]
	local slot_y = mod and mod:get("slot_" .. i .. "_y") or default_positions[i][2]
	scenegraph_definition["background_"..i] = {
		horizontal_alignment = "left",
		parent = "screen",
		vertical_alignment = "top",
		size = portrait_size,
		position = {
			slot_x * hud_scale,
			slot_y * hud_scale,
			20,
		},
	}
end

local name_text_style = table.clone(UIFontSettings.hud_body)
name_text_style.horizontal_alignment = "left"
name_text_style.vertical_alignment = "top"
name_text_style.text_horizontal_alignment = "left"
name_text_style.text_vertical_alignment = "bottom"
name_text_style.size = {
	650 * hud_scale,
	40 * hud_scale,
}
name_text_style.offset = {
	portrait_size[1] + (20 * hud_scale),
	15 * hud_scale,
	2,
}
name_text_style.drop_shadow = true
name_text_style.font_size = 24 * hud_scale

local title_text_style = table.clone(name_text_style)
title_text_style.offset = {
	portrait_size[1] + (20 * hud_scale),
	-10 * hud_scale,
	2,
}
title_text_style.text_color = UIHudSettings.color_tint_main_2

local subtitle_text_style = table.clone(name_text_style)
subtitle_text_style.size = { 650 * hud_scale, 300 * hud_scale }
subtitle_text_style.offset = { portrait_size[1] + (20 * hud_scale), 95 * hud_scale, 2 }
subtitle_text_style.font_size = 24 * hud_scale
subtitle_text_style.text_color = table.clone(UIHudSettings.color_tint_main_2)
subtitle_text_style.text_vertical_alignment = "top"

local widget_definitions = {}

for i = 1, MAX_SLOTS do
	local bg_name = "background_" .. i

	widget_definitions["popup_"..i] = UIWidget.create_definition({
		{
			pass_type = "texture",
			style_id = "portrait",
			value = "content/ui/materials/base/ui_portrait_frame_base_no_render",
			value_id = "portrait",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "top",
				offset = {
					-1 * hud_scale,
					0,
					0,
				},
				color = {
					255,
					255,
					255,
					255,
				},
				material_values = {
					use_placeholder_texture = 1,
				},
			},
		},
		{
			pass_type = "texture",
			style_id = "profile",
			value_id = "profile",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "top",
				material_values = {
					use_placeholder_texture = 0,
				},
				color = {
					255,
					255,
					255,
					255,
				},
				offset = {
					-1 * hud_scale,
					10 * hud_scale,
					1,
				},
				size = {
					portrait_size[1] - (20 * hud_scale),
					portrait_size[2] - (20 * hud_scale),
				},
			},
			visibility_function = function(content, style)
				return style.material_values.texture_map ~= nil
			end,
		},
		{
			pass_type = "texture",
			style_id = "pfp_frame",
			value_id = "pfp_frame",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "top",
				material_values = {
					use_placeholder_texture = 0,
					texture_map = "content/ui/textures/nameplates/portrait_frames/default",
				},
				color = {
					255,
					255,
					255,
					255,
				},
				offset = {
					-1 * hud_scale,
					0,
					2,
				},
				size = portrait_size,
			},
			visibility_function = function(content, style)
				return style.material_values.texture_map and content.use_pfp_frame
			end,
		},
		{
			pass_type = "texture",
			style_id = "frame",
			value = "content/ui/materials/hud/backgrounds/weapon_frame",
			style = {
				horizontal_alignment = "right",
				vertical_alignment = "center",
				color = UIHudSettings.color_tint_main_3,
				offset = {
					0,
					0,
					2,
				},
				size_addition = {
					8 * hud_scale,
					5 * hud_scale,
				},
			},
		},
	}, bg_name)

	widget_definitions["name_text_"..i] = UIWidget.create_definition({
		{
			pass_type = "text",
			style_id = "name_text",
			value = "<name_text>",
			value_id = "name_text",
			style = name_text_style,
		},
	}, bg_name)

	widget_definitions["title_text_"..i] = UIWidget.create_definition({
		{
			pass_type = "text",
			style_id = "title_text",
			value_id = "title_text",
			value = "VOICE COMM",
			style = title_text_style,
		},
	}, bg_name)

	widget_definitions["subtitle_text_"..i] = UIWidget.create_definition({
		{
			pass_type = "text",
			style_id = "subtitle_text",
			value_id = "subtitle_text",
			value = "",
			style = subtitle_text_style,
		},
	}, bg_name)

	widget_definitions["radio_"..i] = UIWidget.create_definition({
		{
			pass_type = "texture",
			style_id = "soundwave",
			value = "content/ui/materials/icons/hud/radio",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "top",
				size = {
					64 * hud_scale,
					32 * hud_scale,
				},
				offset = {
					280 * hud_scale,
					55 * hud_scale,
					0,
				},
				color = UIHudSettings.color_tint_main_2,
			},
		},
	}, bg_name)

	for b = 1, bar_amount do
		local name = "bar_" .. i .. "_" .. b

		widget_definitions[name] = UIWidget.create_definition({
			{
				pass_type = "texture",
				style_id = "background",
				value = "content/ui/materials/backgrounds/default_square",
				style = {
					horizontal_alignment = "left",
					vertical_alignment = "bottom",
					size = bar_size,
					color = UIHudSettings.color_tint_main_4,
					offset = {
						0,
						0,
						0,
					},
				},
			},
			{
				pass_type = "texture",
				style_id = "bar",
				value = "content/ui/materials/backgrounds/default_square",
				style = {
					horizontal_alignment = "left",
					vertical_alignment = "bottom",
					size = bar_size,
					color = UIHudSettings.color_tint_main_2,
					offset = {
						0,
						0,
						1,
					},
				},
			},
			{
				pass_type = "texture",
				style_id = "frame",
				value = "content/ui/materials/frames/line_light",
				style = {
					horizontal_alignment = "left",
					vertical_alignment = "bottom",
					size = bar_size,
					color = UIHudSettings.color_tint_main_3,
					size_addition = {
						4 * hud_scale,
						4 * hud_scale,
					},
					offset = {
						-2 * hud_scale,
						2 * hud_scale,
						2,
					},
				},
			},
		}, bg_name)
	end
end

local animations = {
	popup_enter = {
		{
			end_time = 0,
			name = "hide everything",
			start_time = 0,
			init = function (parent, ui_scenegraph, scenegraph_definition, widgets, params)
				local slot = params.slot
				if not slot then return end
				
				local prefix = "popup_" .. slot
				if widgets[prefix] then widgets[prefix].alpha_multiplier = 0 end
				
				prefix = "name_text_" .. slot
				if widgets[prefix] then widgets[prefix].alpha_multiplier = 0 end
				
				prefix = "title_text_" .. slot
				if widgets[prefix] then widgets[prefix].alpha_multiplier = 0 end
				
				prefix = "subtitle_text_" .. slot
				if widgets[prefix] then widgets[prefix].alpha_multiplier = 0 end
				
				prefix = "radio_" .. slot
				if widgets[prefix] then widgets[prefix].alpha_multiplier = 0 end
				
				for b=1, bar_amount do
					local b_prefix = "bar_" .. slot .. "_" .. b
					if widgets[b_prefix] then widgets[b_prefix].alpha_multiplier = 0 end
				end
			end,
		},
		{
			end_time = 0.2,
			name = "icon_fade_in",
			start_time = 0.0,
			update = function (parent, ui_scenegraph, scenegraph_definition, widgets, progress, params)
				local slot = params.slot
				if not slot then return end
				
				local anim_progress = math.easeOutCubic(progress)
				local popup_widget = widgets["popup_"..slot]
				
				if popup_widget then
					local mod = get_mod("VoxChat")
					local alignment = mod and mod:get("alignment") or "left"
					local start_offset = alignment == "left" and -50 or 50
					local hud_scale_current = mod and mod:get("hud_scale") or 1.0

					popup_widget.alpha_multiplier = anim_progress
					popup_widget.offset[1] = (start_offset - (start_offset * anim_progress)) * hud_scale_current
				end
			end,
		},

		{
			end_time = 0.3,
			name = "text_fade_in",
			start_time = 0.1,
			update = function (parent, ui_scenegraph, scenegraph_definition, widgets, progress, params)
				local slot = params.slot
				if not slot then return end
				
				local anim_progress = math.easeCubic(progress)
				
				local elements = {
					"name_text_" .. slot,
					"title_text_" .. slot,
					"subtitle_text_" .. slot,
					"radio_" .. slot
				}
				for i=1, bar_amount do
					table.insert(elements, "bar_" .. slot .. "_" .. i)
				end
				
				for _, key in ipairs(elements) do
					local widget = widgets[key]
					if widget then
						widget.alpha_multiplier = anim_progress
					end
				end
			end,
		},
	},
	popup_exit = {
		{
			end_time = 0.15,
			name = "text_fade_out",
			start_time = 0,
			update = function (parent, ui_scenegraph, scenegraph_definition, widgets, progress, params)
				local slot = params.slot
				if not slot then return end
				
				local anim_progress = 1 - math.easeOutCubic(progress)

				local elements = {
					"name_text_" .. slot,
					"title_text_" .. slot,
					"subtitle_text_" .. slot,
					"radio_" .. slot
				}
				for i=1, bar_amount do
					table.insert(elements, "bar_" .. slot .. "_" .. i)
				end
				
				for _, key in ipairs(elements) do
					local widget = widgets[key]
					if widget then
						widget.alpha_multiplier = anim_progress
					end
				end
			end,
		},

		{
			end_time = 0.3,
			name = "icon_fade_out",
			start_time = 0.15,
			update = function (parent, ui_scenegraph, scenegraph_definition, widgets, progress, params)
				local slot = params.slot
				if not slot then return end
				
				local anim_progress = 1 - math.easeOutCubic(progress)
				local popup_widget = widgets["popup_"..slot]
				
				if popup_widget then
					local mod = get_mod("VoxChat")
					local alignment = mod and mod:get("alignment") or "left"
					local start_offset = alignment == "left" and -50 or 50
					local hud_scale_current = mod and mod:get("hud_scale") or 1.0

					popup_widget.alpha_multiplier = anim_progress
					popup_widget.offset[1] = (start_offset - (start_offset * anim_progress)) * hud_scale_current
				end
			end,
		},
	},
}

return {
	animations = animations,
	widget_definitions = widget_definitions,
	scenegraph_definition = scenegraph_definition,
    portrait_size = portrait_size,
    bar_amount = bar_amount,
    bar_size = bar_size,
    bar_offset = { portrait_size[1] + (20 * hud_scale), 0, 0 },
    bar_spacing = 10 * hud_scale,
	max_slots = MAX_SLOTS,
}
