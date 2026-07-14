local mod = get_mod("player_voice_popup")

mod:register_hud_element({
    class_name = "HudElementPlayerVoicePopup",
    filename = "player_voice_popup/scripts/mods/player_voice_popup/hud_element_player_voice_popup",
    use_hud_scale = true,
    visibility_groups = {
        "alive",
        "dead",
        "communication_wheel",
        "emote_wheel",
        "tactical_overlay",
        "in_hub_view",
    },
})
