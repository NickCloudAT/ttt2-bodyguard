if SERVER then
	AddCSLuaFile()

	resource.AddFile('materials/vgui/ttt/dynamic/roles/icon_pri.vmt')
end

ROLE.Base = 'ttt_role_base'

ROLE.index = ROLE_BODYGUARD
ROLE.color = Color(60, 55, 55, 255)
ROLE.dkcolor = Color(50, 45, 45, 255)
ROLE.bgcolor = Color(50, 45, 45, 255)
ROLE.abbr = 'bodygrd'
ROLE.surviveBonus = 0 -- bonus multiplier for every survive while another player was killed
ROLE.scoreKillsMultiplier = 1 -- multiplier for kill of player of another team
ROLE.scoreTeamKillsMultiplier = -16 -- multiplier for teamkill
ROLE.preventFindCredits = true
ROLE.preventKillCredits = true
ROLE.preventTraitorAloneCredits = true
ROLE.unknownTeam = true -- player don't know their teammates

roles.InitCustomTeam(ROLE.name, {
    icon = 'vgui/ttt/dynamic/roles/icon_pri',
    color = ROLE.color
})
ROLE.defaultTeam = TEAM_INNOCENT

ROLE.conVarData = {
	pct = 0.15, -- necessary: percentage of getting this role selected (per player)
	maximum = 1, -- maximum amount of roles in a round
	minPlayers = 7, -- minimum amount of players until this role is able to get selected
	credits = 0, -- the starting credits of a specific role
	shopFallback = SHOP_DISABLED,
	togglable = true, -- option to toggle a role for a client if possible (F1 menu)
	random = 33
}


hook.Add("TTT2FinishedLoading", "BodyGuardInitT", function()

	if CLIENT then
		LANG.AddToLanguage("English", BODYGUARD.name, "BodyGuard")
		LANG.AddToLanguage("English", "info_popup_" .. BODYGUARD.name,
			[[You are a Bodyguard!
			Try to protect your Player..]])
		LANG.AddToLanguage("English", "body_found_" .. BODYGUARD.abbr, "They were BodyGuard.")
		LANG.AddToLanguage("English", "search_role_" .. BODYGUARD.abbr, "This person was a BodyGuard!")
		LANG.AddToLanguage("English", "target_" .. BODYGUARD.name, "BodyGuard")
		LANG.AddToLanguage("English", "ttt2_desc_" .. BODYGUARD.name, [[The BodyGuard needs to win with his Players team]])
	end
end)

if SERVER then
	local function InitRoleBodyGuard(ply)
		ply:GiveEquipmentWeapon('stungun')
    end

    hook.Add('TTT2UpdateSubrole', 'TTT2BodyGuardGiveStrip', function(ply, old, new) -- called on normal role set
        if new == ROLE_BODYGUARD then
            InitRoleBodyGuard(ply)
        elseif old == ROLE_BODYGUARD then
            ply:StripWeapon('stungun')
        end
    end)

    hook.Add('PlayerSpawn', 'TTT2PriestGiveStunSpawn', function(ply) -- called on player respawn
        if ply:GetSubRole() ~= ROLE_PRIEST then return end
        InitRoleBodyGuard(ply)
    end)


    hook.Add('TTTBeginRound', 'TTT2BodyGuardBeginRound', function()
      local bodyGuards = {}
      local alivePlayers = {}

      for k,v in ipairs(player.GetAll()) do
        if v:IsTerror() and v:Alive() and not v:IsSpec() and v:GetSubRole() == ROLE_BODYGUARD then
          table.insert(bodyGuards, v)
        elseif v:IsTerror() and v:Alive() and not v:IsSpec() and v:GetSubRole() ~= ROLE_BODYGUARD then
          table.insert(alivePlayers, v)
        end
      end

      local notEnoughAlive = #alivePlayers < #bodyGuards

      if notEnoughAlive then

        local chosenPlayer = table.Random(alivePlayers)

        for k,v in ipairs(bodyGuards) do
          BODYGRD_DATA:SetNewGuard(v, chosenPlayer)
        end

        return
      end

      for k,v in ipairs(bodyGuards) do
        local guardP = table.Random(alivePlayers)
        table.RemoveByValue(alivePlayers, guardP)
        BODYGRD_DATA:SetNewGuard(v, guardP)
      end
    end)

    hook.Add('TTT2SpecialRoleSyncing', 'TTT2RoleBodyGuardMod', function(ply, tbl)
      if ply and ply:GetSubRole() ~= ROLE_BODYGUARD or GetRoundState() == ROUND_POST then return end

      for traitor in pairs(tbl) do
        if traitor:IsTerror() and traitor:Alive() and traitor:GetSubRole() == ROLE_TRAITOR then
          tbl[traitor] = {ROLE_INNOCENT, TEAM_INNOCENT}
        end
      end

    end)

end
