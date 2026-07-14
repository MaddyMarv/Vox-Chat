local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")

local portrait_size = { 100, 120 } -- Extracted from original settings
local bar_amount = 8
local bar_size = { 8, 24 }

local scenegraph_definition = {
	screen = UIWorkspaceSettings.screen,
	background = {
		horizontal_alignment = "left",
		parent = "screen",
		vertical_alignment = "top",
		size = portrait_size,
		position = {
			50,
			300,
			20,
		},
	},
}

local name_text_style = table.clone(UIFontSettings.hud_body)
name_text_style.horizontal_alignment = "left"
name_text_style.vertical_alignment = "top"
name_text_style.text_horizontal_alignment = "left"
name_text_style.text_vertical_alignment = "bottom"
name_text_style.size = {
	650,
	40,
}
name_text_style.offset = {
	portrait_size[1] + 20,
	15,
	2,
}
name_text_style.drop_shadow = true
name_text_style.font_size = 24

local title_text_style = table.clone(name_text_style)
title_text_style.offset = {
	portrait_size[1] + 20,
	-10,
	2,
}
title_text_style.text_color = UIHudSettings.color_tint_main_2

local widget_definitions = {
	popup = UIWidget.create_definition({
		{
			pass_type = "texture",
			style_id = "portrait",
			value = "content/ui/materials/base/ui_portrait_frame_base_no_render",
			value_id = "portrait",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "top",
				offset = {
					-1,
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
					-1,
					10,
					1,
				},
				size = {
					portrait_size[1] - 20,
					portrait_size[2] - 20,
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
					-1,
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
					8,
					5,
				},
			},
		},
	}, "background"),
	name_text = UIWidget.create_definition({
		{
			pass_type = "text",
			style_id = "name_text",
			value = "<name_text>",
			value_id = "name_text",
			style = name_text_style,
		},
	}, "background"),
	title_text = UIWidget.create_definition({
		{
			pass_type = "text",
			style_id = "title_text",
			value_id = "title_text",
			value = "VOICE COMM",
			style = title_text_style,
		},
	}, "background"),
	radio = UIWidget.create_definition({
		{
			pass_type = "texture",
			style_id = "soundwave",
			value = "content/ui/materials/icons/hud/radio",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "top",
				size = {
					64,
					32,
				},
				offset = {
					250,
					55,
					0,
				},
				color = UIHudSettings.color_tint_main_2,
			},
		},
	}, "background"),
}

for i = 1, bar_amount do
	local name = "bar_" .. i

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
					4,
					4,
				},
				offset = {
					-2,
					2,
					2,
				},
			},
		},
	}, "background")
end

local animations = {
	popup_enter = {
		{
			end_time = 0,
			name = "hide everything",
			start_time = 0,
			init = function (parent, ui_scenegraph, scenegraph_definition, widgets)
				for key, widget in pairs(widgets) do
					widget.alpha_multiplier = 0
				end
			end,
		},
		{
			end_time = 0.2,
			name = "icon_fade_in",
			start_time = 0.0,
			update = function (parent, ui_scenegraph, scenegraph_definition, widgets, progress)
				local anim_progress = math.easeOutCubic(progress)
				local popup_widget = widgets.popup

				local mod = get_mod("player_voice_popup")
				local alignment = mod and mod:get("alignment") or "left"
				local start_offset = alignment == "left" and -50 or 50

				popup_widget.alpha_multiplier = anim_progress
				popup_widget.offset[1] = start_offset - (start_offset * anim_progress)
			end,
		},

		{
			end_time = 0.3,
			name = "text_fade_in",
			start_time = 0.1,
			update = function (parent, ui_scenegraph, scenegraph_definition, widgets, progress)
				local anim_progress = math.easeCubic(progress)
				local popup_widget = widgets.popup

				for key, widget in pairs(widgets) do
					if key ~= "popup" then
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
			update = function (parent, ui_scenegraph, scenegraph_definition, widgets, progress)
				local anim_progress = 1 - math.easeOutCubic(progress)

				for key, widget in pairs(widgets) do
					if key ~= "popup" then
						widget.alpha_multiplier = anim_progress
					end
				end
			end,
		},

		{
			end_time = 0.3,
			name = "icon_fade_out",
			start_time = 0.15,
			update = function (parent, ui_scenegraph, scenegraph_definition, widgets, progress)
				local anim_progress = 1 - math.easeOutCubic(progress)
				local popup_widget = widgets.popup

				local mod = get_mod("player_voice_popup")
				local alignment = mod and mod:get("alignment") or "left"
				local start_offset = alignment == "left" and -50 or 50

				popup_widget.alpha_multiplier = anim_progress
				popup_widget.offset[1] = start_offset - (start_offset * anim_progress)
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
    bar_offset = { portrait_size[1] + 20, -35, 0 },
    bar_spacing = 4,
}
