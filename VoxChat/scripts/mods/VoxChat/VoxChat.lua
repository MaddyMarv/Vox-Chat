local mod = get_mod("VoxChat")

mod:register_hud_element({
    class_name = "HudElementPlayerVoicePopup",
    filename = "VoxChat/scripts/mods/VoxChat/hud/hud_element_VoxChat",
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

mod.on_setting_changed = function(setting_id)
    if string.match(setting_id, "^slot_%d+_[xy]$") or setting_id == "hud_scale" then
        local ui_manager = Managers.ui
        if not ui_manager then return end

        local hud = ui_manager._hud
        if not hud or not hud._elements then return end

        local element = hud._elements["HudElementPlayerVoicePopup"]
        if not element then return end

        local hud_scale = mod:get("hud_scale") or 1.0
        local default_positions = {
            { 50, 300 },
            { 50, 440 },
            { 50, 580 },
            { 50, 720 },
        }

        for i = 1, 4 do
            local slot_x = mod:get("slot_" .. i .. "_x") or default_positions[i][1]
            local slot_y = mod:get("slot_" .. i .. "_y") or default_positions[i][2]
            element:set_scenegraph_position("background_"..i, slot_x * hud_scale, slot_y * hud_scale, 20)
        end
    end
end
