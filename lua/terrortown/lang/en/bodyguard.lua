local L = LANG.GetLanguageTableReference("en")

L[BODYGUARD.name] = "BodyGuard"
L["info_popup_" .. BODYGUARD.name] = [[You are a Bodyguard!
Try to protect your Player..]]
L["body_found_" .. BODYGUARD.abbr] = "They were BodyGuard."
L["search_role_" .. BODYGUARD.abbr] = "This person was a BodyGuard!"
L["target_" .. BODYGUARD.name] = "BodyGuard"
L["ttt2_desc_" .. BODYGUARD.name] = [[The BodyGuard needs to win with his Players team]]

L["tooltip_bodyguard_fail_score"] = "BodyGuard Failed: {score}"
L["bodyguard_fail_score"] = "BodyGuard Failed:"
L["title_event_bodyguard_fail"] = "A BodyGuard failed to protect his Target"
L["desc_event_bodyguard_fail"] = "{bodyguard} has failed to protect {target}."

--Convars
L["label_bodygrd_damage_guarded_death"] = "Damage on target death"
L["label_bodygrd_kill_guard_teamkill"] = "Should the bodyguard die if he kills his target?"
L["label_bodygrd_damage_reflect_multiplier"] = "Multiplier for reflect damage."
L["label_bodygrd_damage_dealt_multiplier"] = "Multiplier for damage to target."
L["label_bodygrd_win_alone"] = "Can the bodyguard win alone? (Not recommended)"