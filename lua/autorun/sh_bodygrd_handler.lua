BODYGRD_DATA = {}


if CLIENT then


end


if SERVER then

 function BODYGRD_DATA:SetNewGuard(guard, toGuard)
   if IsValid(toGuard) then
     guard:UpdateTeam(toGuard:GetTeam())
   end
   guard.toguard = toGuard
 end

 function BODYGRD_DATA:GetGuards(ply)
   local guards = {}
   for k,v in ipairs(player.GetAll()) do
     if v:IsTerror() and v:Alive() and not v:IsSpec() and v:GetSubRole() == ROLE_BODYGUARD then
       table.insert(guards, v)
     end
   end
   if #guard == 0 then return nil end
   return guards
 end

 function BODYGRD_DATA:GetGuardedPlayer(ply)
   local toGuard = ply.toguard
   if not IsValid(toGuard) then return nil end
   return toGuard
 end

 hook.Add('PostPlayerDeath', 'TTT2BodygrdDeathHandler', function(ply)
   if ply:GetSubRole() ~= ROLE_BODYGUARD or GetRoundState() ~= ROUND_ACTIVE then return end

   local toGuard = BODYGRD_DATA:GetGuardedPlayer(ply)

   if not IsValid(toGuard) then return end

   BODYGRD_DATA:SetNewGuard(ply, nil)

 end)

end
