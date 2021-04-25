if CLIENT then
	EVENT.icon = Material("vgui/ttt/dynamic/roles/icon_bodygrd")
	EVENT.title = "title_event_bodyguard_fail"

	function EVENT:GetText()
		return {
			{
				string = "desc_event_bodyguard_fail",
				params = {
					bodyguard = self.event.bodyguard.nick,
					target = self.event.target.nick,
				},
				translateParams = true
			}
		}
	end
end

if SERVER then
	function EVENT:Trigger(bodyguard, target)
		self:AddAffectedPlayers(
			{bodyguard:SteamID64(), target:SteamID64()},
			{bodyguard:Nick(), target:Nick()}
		)

		return self:Add({
			bodyguard = {
				nick = bodyguard:Nick(),
				sid64 = bodyguard:SteamID64()
			},
			target = {
				nick = target:Nick(),
				sid64 = target:SteamID64(),
			}
		})
	end

	function EVENT:CalculateScore()
		local event = self.event

		self:SetPlayerScore(event.bodyguard.sid64, {
			score = -2
		})
	end
end

function EVENT:Serialize()
	return self.event.bodyguard.nick .. " has failed to protect " .. self.event.target.nick .. "."
end
