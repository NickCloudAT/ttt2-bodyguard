CreateConVar('ttt_bodygrd_damage_guarded_death', 20, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
CreateConVar('ttt_bodygrd_kill_guard_teamkill', 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
CreateConVar('ttt_bodygrd_damage_reflect_multiplier', 1.5, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
CreateConVar('ttt_bodygrd_damage_dealt_multiplier', 0.1, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
CreateConVar("ttt_bodygrd_win_alone", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

hook.Add("TTTUlxDynamicRCVars", "ttt2_ulx_dynamic_bodyguard_convars", function(tbl)
	tbl[ROLE_BODYGUARD] = tbl[ROLE_BODYGUARD] or {}

	table.insert(tbl[ROLE_BODYGUARD], {cvar = "ttt_bodygrd_kill_guard_teamkill", checkbox = true, desc = "ttt_bodygrd_kill_guard_teamkill (def. 1)"})
  table.insert(tbl[ROLE_BODYGUARD], {cvar = "ttt_bodygrd_win_alone", checkbox = true, desc = "ttt_bodygrd_win_alone (def. 0)"})
	table.insert(tbl[ROLE_BODYGUARD], {cvar = "ttt_bodygrd_damage_guarded_death", slider = true, min = 0, max = 50, decimal = 0, desc = "ttt_bodygrd_damage_guarded_death (def. 20)"})
  table.insert(tbl[ROLE_BODYGUARD], {cvar = "ttt_bodygrd_kill_guard_teamkill", slider = true, min = 0, max = 100, decimal = 2, desc = "ttt_bodygrd_kill_guard_teamkill (def. 1.5)"})
  table.insert(tbl[ROLE_BODYGUARD], {cvar = "ttt_bodygrd_damage_dealt_multiplier", slider = true, min = 0, max = 100, decimal = 2, desc = "ttt_bodygrd_damage_dealt_multiplier (def. 0.1)"})
end)
