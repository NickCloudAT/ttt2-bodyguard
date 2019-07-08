if SERVER then
    resource.AddFile("materials/vgui/ttt/icon_bodyguard_guarding.vmt")
    resource.AddFile("materials/vgui/ttt/hud_icon_guarded.png")
end

if CLIENT then
    hook.Add('Initialize', 'ttt2_role_bodyguard_init', function()
        STATUS:RegisterStatus('ttt2_role_bodyguard_guarding', {
            hud = Material('vgui/ttt/hud_icon_guarded.png'),
            type = 'good'
        })
    end)
end
