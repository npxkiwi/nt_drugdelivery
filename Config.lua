Config = {

    Prop = "prop_drug_package_02",
    -- Liste over alle cutscenes man måske kunne bruge?
    Cutscenes = {
        ["1"] = "mp_int_mcs_15_a1_b",
        ["2"] = "mp_int_mcs_15_a2b",
    },
    NpcData = {
        ["Model"] = "a_m_y_golfer_01",
        ["Coords"] = vector4(-690.35, 515.18, 110.36, 194.34),
        ["Animation"] = "WORLD_HUMAN_AA_SMOKE",
    },
    -- Discord Logs
    Logs = "DISCORD_WEBHOOK", -- Skriv din webhook her :D
    -- Admin/Debug Commands
    Debug = true, -- Hvis du vil teste ting
    fjerncoords = "admin_fjern", -- Admin Command (Fjern coords fra db)
    addcoords = "add_location", --- Admin command (Tilføj coords til db)
    
}
