if engine.ActiveGamemode() ~= "terrortown" then return end

CreateConVar('ttt_bodygrd_damage_guarded_death', 20, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
CreateConVar('ttt_bodygrd_kill_guard_teamkill', 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
CreateConVar('ttt_bodygrd_damage_reflect_multiplier', 1.5, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
CreateConVar('ttt_bodygrd_damage_dealt_multiplier', 0.1, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
CreateConVar("ttt_bodygrd_win_alone", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY})