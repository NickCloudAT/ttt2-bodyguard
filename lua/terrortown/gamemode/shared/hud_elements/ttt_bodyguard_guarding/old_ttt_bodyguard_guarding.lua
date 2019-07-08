local base = "old_ttt_target"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then -- CLIENT
	function HUDELEMENT:PreInitialize()
		BaseClass.PreInitialize(self)

		huds.GetStored("old_ttt"):ForceElement(self.id)

		-- set as NOT fallback default
        self.disabledUnlessForced = true
	end

	function HUDELEMENT:Initialize()
		BaseClass.Initialize(self)

		self:SetBasePos(self.pos.x, self.pos.y - self.size.h - self.margin)
	end

	function HUDELEMENT:Draw()
		local ply = LocalPlayer()

		if not IsValid(ply) then return end

		local guarding = ply:GetNWEntity('guarding_player', nil)

		if HUDEditor.IsEditing then
			self:DrawComponent("GUARDING", edit_colors, "- BodyGuard -")
		elseif guarding and IsValid(guarding) and ply:IsActive() then
			local col_tbl = {
				border = COLOR_WHITE,
				background = ply:GetRoleDkColor(),
				fill = ply:GetRoleColor()
			}

			self:DrawComponent("GUARDING", col_tbl, guarding:Nick())
		end
	end
end
