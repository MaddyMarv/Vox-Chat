local mod = get_mod("VoxChat")

mod:register_hud_element({
    class_name = "HudElementPlayerVoicePopup",
    filename = "VoxChat/scripts/mods/VoxChat/hud_element_VoxChat",
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

mod.on_all_mods_loaded = function()
    local old_mod = get_mod("player_voice_popup")
    if old_mod then
        local warning_text = mod:localize("conflict_warning")
        mod:echo(warning_text)
        mod:notify(warning_text)
    end
end
