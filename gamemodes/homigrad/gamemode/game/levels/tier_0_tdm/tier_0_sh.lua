table.insert(LevelList, "tdm")
tdm = tdm or {}
tdm.Name = "Team Deathmatch"

tdm.teamEncoder = {
	[1] = "red",
	[2] = "blue"
}

print("Loading TDM")

local models = {}

tdm.red = {
	"Red",Color(255,75,75),
	weapons = {"weapon_binokle","weapon_radio","weapon_gurkha","weapon_hands","med_band_big","med_band_small","medkit","painkiller"},
	main_weapon = {"weapon_ak74u","weapon_akm","weapon_remington870","weapon_galil","weapon_rpk","weapon_asval","weapon_p90","weapon_scout","weapon_barret"},
	secondary_weapon = {"weapon_p220","weapon_mateba","weapon_glock"},
	models = tdm.models
}

tdm.blue = {
	"Blue",Color(75,75,255),
	weapons = {"weapon_binokle","weapon_radio","weapon_hands","weapon_kabar","med_band_big","med_band_small","medkit","painkiller","weapon_handcuffs","weapon_taser"},
	main_weapon = {"weapon_hk416","weapon_m4a1","weapon_m3super","weapon_mp7","weapon_xm1014","weapon_fal","weapon_asval","weapon_m249","weapon_p90","weapon_scout","weapon_barret"},
	secondary_weapon = {"weapon_beretta","weapon_p99","weapon_hk_usp"},
	models = tdm.models
}

for i = 1, 9 do 
	table.insert(models,"models/player/group01/male_0" .. i .. ".mdl")
end

for i = 1, 6 do 
	table.insert(models,"models/player/group01/female_0" .. i .. ".mdl") 
end

tdm.models = models

local playsound = false

function tdm.StartRound()
	team.SetColor(1,tdm.red[2])
	team.SetColor(2,tdm.blue[2])

	game.CleanUpMap(false)

	if CLIENT then 
		
		return 
	end

	return tdm.StartRoundSV()
end

if SERVER then return end

tdm.GetTeamName = tdm.GetTeamName

function tdm.HUDPaint_RoundLeft(white)
    local lply = LocalPlayer()
	local name,color = tdm.GetTeamName(lply)

	local startRound = roundTimeStart + 5 - CurTime()
    if startRound > 0 and lply:Alive() then
        if playsound then
            playsound = false
            lply:ScreenFade(SCREENFADE.IN,Color(0,0,0,220),0.5,4)
        end
        
        draw.DrawText( "You are on team: " .." ".. name, "HomigradRoundFont", ScrW() / 2, ScrH() / 2, Color( color.r,color.g,color.b,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "Team Deathmatch", "HomigradRoundFont", ScrW() / 2, ScrH() / 8, Color( color.r,color.g,color.b,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "Kill the other team to win!", "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, Color( 55,55,55,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )
        return
    end
end

function tdm.GetTeamName(ply)
	local round = TableRound()
	local tm = round.teamEncoder[ply:Team()]

	if tm then
		tm = round[tm]

		return tm[1], tm[2]
	end
end

function tdm.ChangeValue(oldName, value)
	local oldValue = tdm[oldName]

	if oldValue ~= value then
		oldValue = value

		return true
	end
end

function tdm.AccurceTime(time)
	return string.FormattedTime(time,"%02i:%02i")
end