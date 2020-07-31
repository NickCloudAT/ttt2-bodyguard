if SERVER then
	AddCSLuaFile()

	resource.AddFile('materials/vgui/ttt/dynamic/roles/icon_bodygrd.vmt')
	resource.AddFile('materials/vgui/ttt/dynamic/roles/icon_bodygrd.vtf')
end


function ROLE:PreInitialize()
	self.index = ROLE_BODYGUARD
	self.color = Color(255, 115, 0, 255)
	self.dkcolor = Color(245, 105, 0, 255)
	self.bgcolor = Color(245, 105, 0, 255)
	self.abbr = 'bodygrd'
	self.surviveBonus = 0 -- bonus multiplier for every survive while another player was killed
	self.scoreKillsMultiplier = 1 -- multiplier for kill of player of another team
	self.scoreTeamKillsMultiplier = -16 -- multiplier for teamkill
	self.preventFindCredits = true
	self.preventKillCredits = true
	self.preventTraitorAloneCredits = true
	self.unknownTeam = true -- player does not know their teammates
	self.preventWin = not GetConVar('ttt_bodygrd_win_alone'):GetBool()

	roles.InitCustomTeam(self.name, {
	    icon = 'vgui/ttt/dynamic/roles/icon_bodygrd',
	    color = self.color
	})
	self.defaultTeam = TEAM_INNOCENT

	self.conVarData = {
		pct = 0.15, -- necessary: percentage of getting this role selected (per player)
		maximum = 1, -- maximum amount of roles in a round
		minPlayers = 8, -- minimum amount of players until this role is able to get selected
		credits = 0, -- the starting credits of a specific role
		shopFallback = SHOP_DISABLED,
		togglable = true, -- option to toggle a role for a client if possible (F1 menu)
		random = 33
	}
end

function ROLE:Initialize()
	if CLIENT then
		LANG.AddToLanguage("English", BODYGUARD.name, "BodyGuard")
		LANG.AddToLanguage("English", "info_popup_" .. BODYGUARD.name,
			[[You are a Bodyguard!
			Try to protect your Player..]])
		LANG.AddToLanguage("English", "body_found_" .. BODYGUARD.abbr, "They were BodyGuard.")
		LANG.AddToLanguage("English", "search_role_" .. BODYGUARD.abbr, "This person was a BodyGuard!")
		LANG.AddToLanguage("English", "target_" .. BODYGUARD.name, "BodyGuard")
		LANG.AddToLanguage("English", "ttt2_desc_" .. BODYGUARD.name, [[The BodyGuard needs to win with his Players team]])
		
		LANG.AddToLanguage("Español", BODYGUARD.name, "Guardaespaldas")
		LANG.AddToLanguage("Español", "info_popup_" .. BODYGUARD.name,
			[[¡Eres un Guardaespaldas!
			Intenta proteger a tu objetivo...]])
		LANG.AddToLanguage("Español", "body_found_" .. BODYGUARD.abbr, "¡Era un Guardaespaldas!")
		LANG.AddToLanguage("Español", "search_role_" .. BODYGUARD.abbr, "Esta persona era un Guardaespaldas.")
		LANG.AddToLanguage("Español", "target_" .. BODYGUARD.name, "Guardaespaldas")
		LANG.AddToLanguage("Español", "ttt2_desc_" .. BODYGUARD.name, [[El Guardaespaldas gana con el equipo de la persona a la cual protege.]])
	end
end



if SERVER then
	local function InitRoleBodyGuard(ply)
		BODYGRD_DATA:FindNewGuardingPlayer(ply, 0.05)
  end

    hook.Add('TTT2UpdateSubrole', 'TTT2BodyGuardGiveStrip', function(ply, old, new) -- called on normal role set
        if new == ROLE_BODYGUARD then
            InitRoleBodyGuard(ply)
        elseif old == ROLE_BODYGUARD then
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

    hook.Add('PlayerSpawn', 'TTT2GuardSpawn', function(ply) -- called on player respawn
        if ply:GetSubRole() ~= ROLE_BODYGUARD or GetRoundState() ~= ROUND_ACTIVE then return end
				if ply:IsTerror() and not ply:IsSpec() then
        	InitRoleBodyGuard(ply)
				end
    end)

    hook.Add('TTT2SpecialRoleSyncing', 'TTT2RoleBodyGuardMod', function(ply, tbl)
      if ply and ply:GetSubRole() ~= ROLE_BODYGUARD or GetRoundState() == ROUND_POST then return end

			local guardedPlayer = BODYGRD_DATA:GetGuardedPlayer(ply)

			if IsValid(guardedPlayer) then
				if not table.HasValue(tbl, guardedPlayer) then
					tbl[guardedPlayer] = {guardedPlayer:GetSubRole() or ROLE_INNOCENT, guardedPlayer:GetTeam() or TEAM_INNOCENT}
				end
			end

      for teamRole in pairs(tbl) do
        if teamRole:HasTeam(ply:GetTeam()) and teamRole ~= ply and teamRole ~= guardedPlayer and teamRole:GetSubRole() ~= ROLE_DETECTIVE and not teamRole:GetNWBool('role_found', false) then
          tbl[teamRole] = {ROLE_INNOCENT, TEAM_INNOCENT}
        end
      end

    end)


		hook.Add('TTT2SpecialRoleSyncing', 'TTT2RoleBodyGuardMod2', function(ply, tbl)
			if ply and ply:GetSubRole() == ROLE_BODYGUARD or GetRoundState() == ROUND_POST then return end

			if not BODYGRD_DATA:HasGuards(ply) then return end

			local guards = BODYGRD_DATA:GetGuards(ply)

			for k,p in ipairs(guards) do
				if not table.HasValue(tbl, p) then
					tbl[p] = {p:GetSubRole() or ROLE_INNOCENT, p:GetTeam() or TEAM_INNOCENT}
				end
			end

		end)

		hook.Add('TTT2ModifyRadarRole', "TTT2RadarBodyguardFix", function(ply, scan)
			if ply:GetSubRole() ~= ROLE_BODYGUARD or GetRoundState() ~= ROUND_ACTIVE then return end

			if BODYGRD_DATA:IsGuardOf(ply, scan) then return end

			if not scan:HasTeam(ply:GetTeam()) then return end

			return ROLE_INNOCENT, TEAM_INNOCENT

		end)

		hook.Add('TTT2TellTraitors', 'TTT2HideTraitorMessageBodyGuard', function(tmp, ply)
			if ply:GetSubRole() ~= ROLE_BODYGUARD then return end
			return false
		end)

		hook.Add('TTT2AvoidTeamChat', 'TTT2AvoidBodyGuardChat', function(sender, team, msg)
			if sender:GetSubRole() ~= ROLE_BODYGUARD or (sender:GetSubRole() == ROLE_BODYGUARD and team == TEAM_INNOCENT) or GetRoundState() ~= ROUND_ACTIVE then return end
			return false
		end)

		hook.Add('TTT2OverrideDisabledSync', 'TTT2BodyGuardBypassDisSync', function(ply, p)
			if not IsValid(p) or not IsValid(ply) or ply:GetSubRole() ~= ROLE_BODYGUARD then return end

			if not BODYGRD_DATA:IsGuardOf(ply, p) then return end

			return true
		end)

end
