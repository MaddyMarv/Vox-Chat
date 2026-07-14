local mod = get_mod("player_voice_popup")

return {
    name = "Player Voice Popup",
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
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
        },
    },
}
