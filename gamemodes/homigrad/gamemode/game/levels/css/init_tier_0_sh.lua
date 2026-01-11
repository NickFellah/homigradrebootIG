table.insert(LevelList,"css")
css = {}
css.Name = "Counter Strike: Source"
css.points = {}

css.WinPoints = css.WinPoints or {}
css.WinPoints[1] = css.WinPoints[1] or 0
css.WinPoints[2] = css.WinPoints[2] or 0

css.terrorists = {"Terrorists",Color(176,0,0),
	weapons = {"megamedkit","weapon_binokle","weapon_hands","weapon_hg_hatchet","med_band_small","med_band_big","med_band_small","painkiller","weapon_handcuffs","weapon_radio"},
	main_weapon = {"weapon_asval", "weapon_mp5", "weapon_m3super"},
	secondary_weapon = {"weapon_beretta","weapon_p99","weapon_beretta"},
	models = {"models/player/leet.mdl","models/player/phoenix.mdl","models/player/arctic.mdl","models/player/guerilla.mdl"}
}

css.counterterrorists = {"Counter-Terrorists",Color(79,59,187),
	weapons = {"megamedkit","weapon_binokle","weapon_hg_hatchet","weapon_hands","med_band_big","med_band_small","medkit","painkiller","weapon_handcuffs","weapon_radio"},
	main_weapon = {"weapon_m4a1","weapon_mp7","weapon_galil"},
	secondary_weapon = {"weapon_hk_usp", "weapon_mateba"},
	models = {"models/player/riot.mdl","models/player/gasmask.mdl","models/player/swat","models/player/urban.mdl"}
}

css.teamEncoder = {
	[1] = "terrorists",
	[2] = "counterterrorists"
}

function css.StartRound()
    local ply = player.GetAll()
	game.CleanUpMap(false)
    css.points = {}
    if !file.Read( "homigrad/maps/controlpoint/"..game.GetMap()..".txt", "DATA" ) and SERVER then
        print("Nicky add the spawn points on this map or else demoted!!!") 
        PrintMessage(HUD_PRINTCENTER, "Nicky add the spawn points on this map or else demoted!!!")
    end

    css.LastWave = CurTime()

    css.WinPoints = {}
    css.WinPoints[1] = 0
    css.WinPoints[2] = 0

	team.SetColor(1,red)
	team.SetColor(2,blue)

    for i, point in pairs(SpawnPointsList.controlpoint[3]) do
        SetGlobalInt(i .. "PointProgress", 0)
        SetGlobalInt(i .. "PointCapture", 0)
        css.points[i] = {}
    end

    SetGlobalInt("CP_respawntime", CurTime())

	if CLIENT then return end

    timer.Create("CP_ThinkAboutPoints", 1, 0, function() --подумай о точках... засунул в таймер для оптимизации, ибо там каждый тик игроки в сфере подглядываются, ну и в целом для удобства
        css.PointsThink()
    end)

    css.StartRoundSV()
end

css.RoundRandomDefalut = 1
css.SupportCenter = true

css.NoSelectRandom = true
