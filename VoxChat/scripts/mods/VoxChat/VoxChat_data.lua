local mod = get_mod("VoxChat")

return {
    name = "VoxChat",
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "general_settings",
                type = "group",
                title = "general_tab",
                tab = mod:localize("general_tab"),
                sub_widgets = {
                    {
                        setting_id = "enable_voip",
                        type = "checkbox",
                        default_value = true,
                        title = "enable_voip",
                        tooltip = "enable_voip_description",
                    },
                    {
                        setting_id = "voip_priority",
                        type = "checkbox",
                        default_value = false,
                        title = "voip_priority",
                        tooltip = "voip_priority_description",
                    },
                    {
                        setting_id = "show_self",
                        type = "checkbox",
                        default_value = true,
                        title = "show_self",
                        tooltip = "show_self_description",
                    },
                    {
                        setting_id = "alignment",
                        type = "dropdown",
                        default_value = "left",
                        options = {
                            { text = "left", value = "left" },
                            { text = "right", value = "right" },
                        },
                        title = "alignment",
                        tooltip = "alignment_description",
                    },
                    {
                        setting_id = "portrait_style",
                        type = "dropdown",
                        default_value = "pfp",
                        options = {
                            { text = "pfp", value = "pfp" },
                            { text = "3d", value = "3d" },
                            { text = "tv", value = "tv" },
                        },
                        title = "portrait_style",
                        tooltip = "portrait_style_description",
                    },
                    {
                        setting_id = "mission_only",
                        type = "checkbox",
                        default_value = false,
                        title = "mission_only",
                        tooltip = "mission_only_description",
                    },
                }
            },
            {
                setting_id = "in_game_dialogue_group",
                type = "group",
                title = "in_game_dialogue_tab",
                tab = mod:localize("in_game_dialogue_tab"),
                sub_widgets = {
                    {
                        setting_id = "in_game_dialogue",
                        type = "checkbox",
                        default_value = false,
                        title = "in_game_dialogue",
                        tooltip = "in_game_dialogue_description",
                    },
                    {
                        setting_id = "vox_distance",
                        type = "numeric",
                        default_value = 15,
                        range = {0, 50},
                        title = "vox_distance",
                        tooltip = "vox_distance_description",
                    },
                    {
                        setting_id = "show_self_dialogue",
                        type = "checkbox",
                        default_value = true,
                        title = "show_self_dialogue",
                        tooltip = "show_self_dialogue_description",
                    },
                    {
                        setting_id = "show_subtitles",
                        type = "checkbox",
                        default_value = true,
                        title = "show_subtitles",
                        tooltip = "show_subtitles_description",
                    },
                    {
                        setting_id = "subtitle_offset_x",
                        type = "numeric",
                        default_value = 0,
                        range = {-500, 500},
                        title = "subtitle_offset_x",
                        tooltip = "subtitle_offset_x_description",
                    },
                    {
                        setting_id = "subtitle_offset_y",
                        type = "numeric",
                        default_value = 95,
                        range = {-500, 500},
                        title = "subtitle_offset_y",
                        tooltip = "subtitle_offset_y_description",
                    },
                    {
                        setting_id = "subtitle_font_size",
                        type = "numeric",
                        default_value = 24,
                        range = {10, 60},
                        title = "subtitle_font_size",
                        tooltip = "subtitle_font_size_description",
                    },
                    {
                        setting_id = "subtitle_color_r",
                        type = "numeric",
                        default_value = 241,
                        range = {0, 255},
                        title = "subtitle_color_r",
                    },
                    {
                        setting_id = "subtitle_color_g",
                        type = "numeric",
                        default_value = 231,
                        range = {0, 255},
                        title = "subtitle_color_g",
                    },
                    {
                        setting_id = "subtitle_color_b",
                        type = "numeric",
                        default_value = 163,
                        range = {0, 255},
                        title = "subtitle_color_b",
                    },
                    {
                        setting_id = "subtitle_color_a",
                        type = "numeric",
                        default_value = 255,
                        range = {0, 255},
                        title = "subtitle_color_a",
                    },
                }
            }
        },
    },
}
