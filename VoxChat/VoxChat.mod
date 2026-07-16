return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`VoxChat` encountered an error loading the Darktide Mod Framework.")

        new_mod("VoxChat", {
            mod_script       = "VoxChat/scripts/mods/VoxChat/VoxChat",
            mod_data         = "VoxChat/scripts/mods/VoxChat/VoxChat_data",
            mod_localization = "VoxChat/scripts/mods/VoxChat/VoxChat_localization",
        })
    end,
    packages = {}
}
