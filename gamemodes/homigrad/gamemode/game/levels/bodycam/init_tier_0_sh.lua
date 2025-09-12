--table.insert(LevelList,"hl2bodycam")
hl2bodycam = {}
hl2bodycam.Name = "Half Life 2 BodyCam"

local models = {}
for i = 1,9 do table.insert(models,"models/player/group03/male_0" .. i .. ".mdl") end

hl2bodycam.red = {"Resistance",Color(125,95,60),
	weapons = {"weapon_hands","med_band_big","med_band_small","weapon_radio"},
	main_weapon = {"weapon_sar2","weapon_spas12","weapon_akm","weapon_mp7","weapon_scout","weapon_barrett"},
	secondary_weapon = {"weapon_hk_usp","weapon_p220"},
	models = models
}


hl2bodycam.blue = {"Combine",Color(75,75,125),
	weapons = {"weapon_hands"},
	main_weapon = {"weapon_sar2","weapon_spas12","weapon_mp7","weapon_scout","weapon_barrett"},
	secondary_weapon = {"weapon_hk_usp"},
	models = {"models/player/combine_soldier.mdl"}
}

hl2bodycam.teamEncoder = {
	[1] = "red",
	[2] = "blue"
}

function hl2bodycam.StartRound()
	game.CleanUpMap(false)

	team.SetColor(1,hl2bodycam.red[2])
	team.SetColor(2,hl2bodycam.blue[2])

	if CLIENT then

		hl2bodycam.StartRoundCL()
		return
	end

	hl2bodycam.StartRoundSV()
end
hl2bodycam.RoundRandomDefalut = 2
hl2bodycam.SupportCenter = true
