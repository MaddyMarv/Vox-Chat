local mod = get_mod("VoxChat")

return {
    name = "VoxChat",
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "voip_group",
                type = "group",
                title = "voip_tab",
                tab = mod:localize("voip_tab"),
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
                        setting_id = "voip_distance",
                        type = "numeric",
                        default_value = 0,
                        range = {0, 50},
                        title = "voip_distance",
                        tooltip = "voip_distance_description",
                    },
                    {
                        setting_id = "show_self",
                        type = "checkbox",
                        default_value = true,
                        title = "show_self",
                        tooltip = "show_self_description",
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
                        setting_id = "dialogue_filter_mode",
                        type = "dropdown",
                        default_value = "all",
                        options = {
                            { text = "filter_mode_all", value = "all" },
                            { text = "filter_mode_combat_only", value = "combat_only" },
                            { text = "filter_mode_banter_only", value = "banter_only" },
                        },
                        title = "dialogue_filter_mode",
                        tooltip = "dialogue_filter_mode_description",
                    },
                    {
                        setting_id = "vox_distance",
                        type = "numeric",
                        default_value = 0,
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
                }
            },
            {
                setting_id = "appearance_group",
                type = "group",
                title = "appearance_tab",
                tab = mod:localize("appearance_tab"),
                sub_widgets = {
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
                        setting_id = "max_slots",
                        type = "numeric",
                        default_value = 2,
                        range = {1, 4},
                        title = "max_slots",
                        tooltip = "max_slots_description",
                    },
                    {
                        setting_id = "hud_scale",
                        type = "numeric",
                        default_value = 1.0,
                        range = {0.5, 2.0},
                        decimals_number = 2,
                        step_size_value = 0.05,
                        title = "hud_scale",
                        tooltip = "hud_scale_description",
                    },
                    {
                        setting_id = "mission_only",
                        type = "checkbox",
                        default_value = false,
                        title = "mission_only",
                        tooltip = "mission_only_description",
                    },
                    {
                        setting_id = "name_display_format",
                        type = "dropdown",
                        default_value = "character",
                        options = {
                            { text = "format_character", value = "character" },
                            { text = "format_account", value = "account" },
                            { text = "format_character_account", value = "character_account" },
                            { text = "format_account_character", value = "account_character" },
                        },
                        title = "name_display_format",
                        tooltip = "name_display_format_description",
                    },
                }
            },
            {
                setting_id = "subtitles_group",
                type = "group",
                title = "subtitles_tab",
                tab = mod:localize("subtitles_tab"),
                sub_widgets = {
                    {
                        setting_id = "show_subtitles",
                        type = "checkbox",
                        default_value = true,
                        title = "show_subtitles",
                        tooltip = "show_subtitles_description",
                    },
                    {
                        setting_id = "scroll_subtitles",
                        type = "checkbox",
                        default_value = true,
                        title = "scroll_subtitles",
                        tooltip = "scroll_subtitles_description",
                    },
                    {
                        setting_id = "scroll_subtitles_length",
                        type = "numeric",
                        default_value = 40,
                        range = {10, 150},
                        title = "scroll_subtitles_length",
                        tooltip = "scroll_subtitles_length_description",
                    },
                    {
                        setting_id = "scroll_subtitles_speed",
                        type = "numeric",
                        default_value = 0.2,
                        range = {0.01, 5.0},
                        decimals_number = 2,
                        title = "scroll_subtitles_speed",
                        tooltip = "scroll_subtitles_speed_description",
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
                        setting_id = "subtitle_color",
                        type = "color",
                        default_value = { 255, 241, 231, 163 },
                        title = "subtitle_color",
                    },
                }
            }
        },
    },
}
