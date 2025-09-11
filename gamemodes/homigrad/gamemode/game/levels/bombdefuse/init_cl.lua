bombdefuse.GetTeamName = tdm.GetTeamName

local playsound = false
function bombdefuse.StartRoundCL()
    playsound = true
end

function bombdefuse.HUDPaint_RoundLeft(white)
    local lply = LocalPlayer()
	local name,color = bombdefuse.GetTeamName(lply)

	local startRound = roundTimeStart + 5 - CurTime()
    if startRound > 0 and lply:Alive() then
        if playsound then
            playsound = false
            --surface.PlaySound("snd_jack_hmcd_deathmatch.mp3")
            lply:ScreenFade(SCREENFADE.IN,Color(0,0,0,220),0.5,4)
        end
        

        draw.DrawText( "You are on team: " .. name, "HomigradFontBig", ScrW() / 2, ScrH() / 2, Color( color.r,color.g,color.b,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "Bomb Defusal", "HomigradRoundFont", ScrW() / 2, ScrH() / 8, Color( 155,55,155,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "Plant/Defuse The Bomb Or Neutralise The Enemy Team!", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 155,155,155,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )
        return
    end
end