local base = "pure_skin_target"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base
HUDELEMENT.icon = Material("vgui/ttt/icon_bodyguard_guarding")

if CLIENT then -- CLIENT

	function HUDELEMENT:PreInitialize()
		BaseClass.PreInitialize(self)

		huds.GetStored("pure_skin"):ForceElement(self.id)

		-- set as fallback default, other skins have to be set to true!
        self.disabledUnlessForced = false
	end

	function HUDELEMENT:Draw()
		local ply = LocalPlayer()

		if not IsValid(ply) then return end

		local guarding = ply:GetNWEntity('guarding_player', nil)

		if HUDEditor.IsEditing then
			self:DrawComponent("- BodyGuard -")
		elseif guarding and IsValid(guarding) and ply:IsActive() then
			self:DrawComponent(guarding:Nick())
		end
	end
end
