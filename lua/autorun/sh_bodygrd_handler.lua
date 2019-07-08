BODYGRD_DATA = {}


if CLIENT then

  net.Receive("TTT2BodyGrdNewGuardMessage", function()
    local name = net.ReadString()

    local ply = LocalPlayer()

    chat.AddText(Color(0, 255, 50), "[BodyGuard] " .. name .. " is now your BodyGuard.")

    chat.PlaySound()

    STATUS:AddStatus('ttt2_role_bodyguard_guarding')

  end)

  net.Receive("TTT2BodyGrdNewGuardingMessage", function()
    local name = net.ReadString()
    local role = net.ReadString()
    local roleColor = net.ReadColor()

    local ply = LocalPlayer()

    chat.AddText("[BodyGuard] You are guarding " .. name .. ". His Role: ", roleColor, role)

    chat.PlaySound()

  end)

  net.Receive("TTT2BodyGrdGuardDeathMessage", function()
    chat.AddText(Color(255, 0, 0), "[BodyGuard] Your BodyGuard has died!")

    chat.PlaySound()

    STATUS:RemoveStatus('ttt2_role_bodyguard_guarding')

  end)

  hook.Add('TTTPrepareRound', 'TTT2ResetBodyGuardValues', function()
    local ply = LocalPlayer()
    ply:SetNWEntity('guarding_player', nil)
  end)

  hook.Add('TTT2UpdateSubrole', 'TTT2BodyGuardSubChange', function(ply, old, new) -- called on normal role set
      if old == ROLE_BODYGUARD then
          ply:SetNWEntity('guarding_player', nil)
      end
  end)

end


if SERVER then

  util.AddNetworkString("TTT2BodyGrdNewGuardMessage")
  util.AddNetworkString("TTT2BodyGrdNewGuardingMessage")
  util.AddNetworkString("TTT2BodyGrdGuardDeathMessage")

 function BODYGRD_DATA:SetNewGuard(guard, toGuard)

   guard:SetNWEntity("guarding_player", toGuard)

   if IsValid(toGuard) then
     guard:UpdateTeam(toGuard:GetTeam())

     local roleData = roles.GetByIndex(toGuard:GetSubRole())

     net.Start("TTT2BodyGrdNewGuardingMessage")
     net.WriteString(toGuard:Nick())
     net.WriteString(roleData.name)
     net.WriteColor(roleData.color)

     net.Send(guard)

     net.Start("TTT2BodyGrdNewGuardMessage")
     net.WriteString(guard:Nick())

     net.Send(toGuard)

     SendFullStateUpdate()

   end
 end

 function BODYGRD_DATA:FindNewGuardingPlayer(ply, delay)

   if delay then
     timer.Simple(delay, function()
        BODYGRD_DATA:FindNewGuardingPlayer(ply)
     end)
     return
   end

   if not ply or not IsValid(ply) then return end
   if not ply:IsTerror() or ply:IsSpec() or ply:GetSubRole() ~= ROLE_BODYGUARD then return end
   local alivePlayers = {}

   for k,v in ipairs(player.GetAll()) do
     if v:IsTerror() and v:Alive() and not v:IsSpec() and v:GetSubRole() ~= ROLE_BODYGUARD and v ~= ply then
       table.insert(alivePlayers, v)
     end
   end

   local tmp = table.Copy(alivePlayers)

   for k,v in ipairs(alivePlayers) do
     if BODYGRD_DATA:HasGuards(v) then
       table.RemoveByValue(tmp, v)
     end
   end

   local playerAvailable = #tmp > 0

   if playerAvailable then
     local newToGuard = table.Random(tmp)
     BODYGRD_DATA:SetNewGuard(ply, newToGuard)
     return
   end

   local newToGuard = table.Random(alivePlayers)

   BODYGRD_DATA:SetNewGuard(ply, newToGuard)

 end

 function BODYGRD_DATA:GetGuards(ply)
   local guards = {}
   for k,v in ipairs(player.GetAll()) do
     if v:IsTerror() and v:Alive() and not v:IsSpec() and v:GetSubRole() == ROLE_BODYGUARD then
       local nwGuard = v:GetNWEntity("guarding_player")
       if IsValid(nwGuard) then
         if nwGuard == ply then table.insert(guards, v) end
       end
     end
   end
   if #guards == 0 then return nil end
   return guards
 end

 function BODYGRD_DATA:HasGuards(ply)
   local guards = BODYGRD_DATA:GetGuards(ply)

   if not guards then return false end
   if #guards <= 0 then return false end

   return true

 end

 function BODYGRD_DATA:IsGuardOf(guard, check)
   if not BODYGRD_DATA:HasGuards(check) then return false end

   local guards = BODYGRD_DATA:GetGuards(check)

   return table.HasValue(guards, guard)

 end

 function BODYGRD_DATA:GetGuardedPlayer(ply)
   local toGuard = ply:GetNWEntity("guarding_player")
   if not IsValid(toGuard) then return nil end
   return toGuard
 end

 hook.Add('PlayerDeath', 'TTT2BodygrdDeathHandler', function(ply, infl, attacker)
   if ply:GetSubRole() ~= ROLE_BODYGUARD or GetRoundState() ~= ROUND_ACTIVE then return end

   local toGuard = BODYGRD_DATA:GetGuardedPlayer(ply)

   if not IsValid(toGuard) then return end

   BODYGRD_DATA:SetNewGuard(ply, nil)

   net.Start("TTT2BodyGrdGuardDeathMessage")
   net.Send(toGuard)

   SendFullStateUpdate()

 end)

 hook.Add('PlayerDeath', 'TTT2GuardedDeathHandler', function(ply, infl, attacker)
   if ply:GetSubRole() == ROLE_BODYGUARD or GetRoundState() ~= ROUND_ACTIVE then return end

   local guards = BODYGRD_DATA:GetGuards(ply)

   if not BODYGRD_DATA:HasGuards(ply) then return end

   for k,v in ipairs(guards) do
     if v == attacker then
       if GetConVar('ttt_bodygrd_kill_guard_teamkill'):GetBool() then
        v:Kill()
        BODYGRD_DATA:SetNewGuard(v, nil)
       end
     end
   end
 end)

 hook.Add('PostPlayerDeath', 'TTT2GuardedDeathHandler2', function(ply)
   if ply:GetSubRole() == ROLE_BODYGUARD or GetRoundState() ~= ROUND_ACTIVE then return end

   local guards = BODYGRD_DATA:GetGuards(ply)

   if not BODYGRD_DATA:HasGuards(ply) then return end

   for k,v in ipairs(guards) do
     BODYGRD_DATA:SetNewGuard(v, nil)
     BODYGRD_DATA:FindNewGuardingPlayer(v)
     v:TakeDamage(GetConVar('ttt_bodygrd_damage_guarded_death'):GetInt(), v, v)
   end

 end)


 hook.Add('PlayerDisconnected', 'TTT2GuardedDisconnectHandler', function(ply)
   if ply:GetSubRole() == ROLE_BODYGUARD or GetRoundState() ~= ROUND_ACTIVE then return end

   local guards = BODYGRD_DATA:GetGuards(ply)

   if not BODYGRD_DATA:HasGuards(ply) then return end

   for k,v in ipairs(guards) do
     BODYGRD_DATA:SetNewGuard(v, nil)
     BODYGRD_DATA:FindNewGuardingPlayer(v, 0.05)
     v:TakeDamage(GetConVar('ttt_bodygrd_damage_guarded_death'):GetInt(), v, v)
   end

 end)

 hook.Add('PlayerDisconnected', 'TTT2GuardDisconnectHandler', function(ply)
   if ply:GetSubRole() ~= ROLE_BODYGUARD or GetRoundState() ~= ROUND_ACTIVE then return end

   local toGuard = BODYGRD_DATA:GetGuardedPlayer(ply)

   if not IsValid(toGuard) then return end

   net.Start("TTT2BodyGrdGuardDeathMessage")
   net.Send(toGuard)

   SendFullStateUpdate()

 end)


 hook.Add('EntityTakeDamage', 'ReflectGuardedDamage', function(ply, dmginfo)
    if not BODYGRD_DATA:HasGuards(ply) or GetRoundState() ~= ROUND_ACTIVE then return end

    local attacker = dmginfo:GetAttacker()

    if not IsValid(attacker) or not attacker:IsPlayer() then return end

    if not attacker:IsTerror() then return end

    if not BODYGRD_DATA:IsGuardOf(attacker, ply) then return end

    local damage = dmginfo:GetDamage()

    dmginfo:ScaleDamage(GetConVar('ttt_bodygrd_damage_dealt_multiplier'):GetFloat())


    attacker:TakeDamage(damage*GetConVar('ttt_bodygrd_damage_reflect_multiplier'):GetFloat(), attacker, attacker)

 end)

end
