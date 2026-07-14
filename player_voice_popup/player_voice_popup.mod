return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`player_voice_popup` encountered an error loading the Darktide Mod Framework.")

        new_mod("player_voice_popup", {
            mod_script       = "player_voice_popup/scripts/mods/player_voice_popup/player_voice_popup",
            mod_data         = "player_voice_popup/scripts/mods/player_voice_popup/player_voice_popup_data",
            mod_localization = "player_voice_popup/scripts/mods/player_voice_popup/player_voice_popup_localization",
        })
    end,
    packages = {}
}
