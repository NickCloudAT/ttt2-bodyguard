if SERVER then
	AddCSLuaFile()

	resource.AddFile('materials/vgui/ttt/dynamic/roles/icon_bodygrd.vmt')
	resource.AddFile('materials/vgui/ttt/dynamic/roles/icon_bodygrd.vtf')
end

ROLE.Base = 'ttt_role_base'

ROLE.index = ROLE_BODYGUARD
ROLE.color = Color(255, 115, 0, 255)
ROLE.dkcolor = Color(245, 105, 0, 255)
ROLE.bgcolor = Color(245, 105, 0, 255)
ROLE.abbr = 'bodygrd'
ROLE.surviveBonus = 0 -- bonus multiplier for every survive while another player was killed
ROLE.scoreKillsMultiplier = 1 -- multiplier for kill of player of another team
ROLE.scoreTeamKillsMultiplier = -16 -- multiplier for teamkill
ROLE.preventFindCredits = true
ROLE.preventKillCredits = true
ROLE.preventTraitorAloneCredits = true
ROLE.unknownTeam = true -- player don't know their teammates

roles.InitCustomTeam(ROLE.name, {
    icon = 'vgui/ttt/dynamic/roles/icon_bodygrd',
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
		timer.Simple(0.05, function()
			if ply:GetSubRole() ~= ROLE_BODYGUARD then return end
			if ply:IsTerror() and not ply:IsSpec() then
				BODYGRD_DATA:FindNewGuardingPlayer(ply)
			end
		end)
  end

    hook.Add('TTT2UpdateSubrole', 'TTT2BodyGuardGiveStrip', function(ply, old, new) -- called on normal role set
        if new == ROLE_BODYGUARD then
            InitRoleBodyGuard(ply)
        elseif old == ROLE_BODYGUARD then
            ply:StripWeapon('stungun')
						ply:SetNWEntity('guarding_player', nil)
        end
    end)

		hook.Add("TTT2UpdateTeam", "TTT2BodyGuardTeamChanged", function(ply, oldTeam, team)
			if ply:GetSubRole() == ROLE_BODYGUARD or GetRoundState() ~= ROUND_ACTIVE then return end

			if not BODYGRD_DATA:HasGuards(ply) then return end

			for k,v in ipairs(BODYGRD_DATA:GetGuards(ply)) do
				v:UpdateTeam(team)
			end
			SendFullStateUpdate()
		end)

    hook.Add('PlayerSpawn', 'TTT2GuardGiveStunSpawn', function(ply) -- called on player respawn
        if ply:GetSubRole() ~= ROLE_BODYGUARD then return end
				if ply:IsTerror() and not ply:IsSpec() then
        	InitRoleBodyGuard(ply)
				end
    end)


    --[[hook.Add('TTTBeginRound', 'TTT2BodyGuardBeginRound', function()
			for k,v in ipairs(player.GetAll() do
				if v:GetSubRole() == ROLE_BODYGUARD then
					BODYGRD_DATA:FindNewGuardingPlayer(v)
				end
			end)
    end]]--

    hook.Add('TTT2SpecialRoleSyncing', 'TTT2RoleBodyGuardMod', function(ply, tbl)
      if ply and ply:GetSubRole() ~= ROLE_BODYGUARD or GetRoundState() == ROUND_POST then return end

      for teamRole in pairs(tbl) do
        if teamRole:IsTerror() and teamRole:Alive() and teamRole:HasTeam(ply:GetTeam()) and teamRole ~= ply and teamRole:GetSubRole() ~= ROLE_DETECTIVE then
          tbl[teamRole] = {ROLE_INNOCENT, TEAM_INNOCENT}
        end
      end

    end)

end
