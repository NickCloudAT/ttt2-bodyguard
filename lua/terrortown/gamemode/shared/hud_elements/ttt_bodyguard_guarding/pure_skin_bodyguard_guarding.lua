if SERVER then resource.AddFile("materials/vgui/ttt/icon_deathgrip.vmt") end

local base = "pure_skin_target"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base
HUDELEMENT.icon = Material("vgui/ttt/icon_deathgrip")

if CLIENT then -- CLIENT

	function HUDELEMENT:PreInitialize()
		BaseClass.PreInitialize(self)

		huds.GetStored("pure_skin"):ForceElement(self.id)
	end

	function HUDELEMENT:Draw()
		local ply = LocalPlayer()

		if not IsValid(ply) then return end

		local guarding = ply:GetNWEntity('guarding_player')

		if HUDEditor.IsEditing then
			self:DrawComponent("- BodyGuard -")
		elseif guarding and IsValid(guarding) and ply:IsActive() then
			self:DrawComponent(guarding:Nick())
		end
	end
end
