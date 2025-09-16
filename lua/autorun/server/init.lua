resource.AddFile("resource/localization/en/homigradlocales.properties")
--resource.AddFile("resource/localization/de/homigrad.lang")
--resource.AddFile("resource/localization/ru/homigrad.lang")
--resource.AddFile("resource/localization/es-ES/homigrad.lang")
--resource.AddFile("resource/localization/en-PT/homigrad.lang")
--resource.AddFile("resource/localization/sv-SE/homigrad.lang")
resource.AddFile("materials/vgui/fmt/homicide.png")



util.AddNetworkString( "SIX.SIDETO" )
SIX = SIX or {}

CreateConVar( "lean_speed", 5, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_CLIENTCMD_CAN_EXECUTE } )
CreateConVar( "lean_strength", 11, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_CLIENTCMD_CAN_EXECUTE } )

local cvar_st = GetConVar( "lean_strength" ):GetInt()

net.Receive("SIX.SIDETO", function(len, pl)
    local side = net.ReadInt(3)
    cvar_st = GetConVar( "lean_strength" ):GetInt() -- updating

    if side == 1 then
        side = -cvar_st * 2.1
    elseif side == 2 then
        side = cvar_st * 2.1
    elseif side == 0 then
        side = 0
    end

    if not SIX[pl:SteamID()] then
        SIX[pl:SteamID()] = {
            pl = pl,
            side = side,
            angle = 0.01,
            oldangle = 0,
        }
    end
    SIX[pl:SteamID()].side = side
end)

hook.Add("Think","SIX.SENDTOSIDE",function()
    for k, v in pairs(SIX) do

        if not IsValid(v.pl) or SIX[k].angle == 0 then
            SIX[k] = nil
            continue
        end

        SIX[k].angle = Lerp(GetConVar( "lean_speed" ):GetInt()/100,SIX[k].oldangle,SIX[k].side)

        SIX[k].oldangle = SIX[k].angle

        v.pl:ManipulateBoneAngles( 2, Angle( SIX[k].angle,0,0 ) )

    end
end)

local constructSetup = true

local allowedMaps = {
    ["gm_construct"] = true,
    ["gm_flatgrass"] = true,
}

local function DoConstructSetup(ply, manual)
    if manual == false then
        if not allowedMaps[game.GetMap()] then print("return1") return end
    end
    
    if not IsValid(ply) or not ply:IsAdmin() then print("return2") return end
    if not constructSetup then print("return3") return end

    constructSetup = false

    if manual == true then ply:ChatPrint(ply:GetName().. " Started The Construct Setup! Please wait...") end
    timer.Simple(2, function()
        if not IsValid(ply) then return end
        ply:ConCommand("say !bot 3")
        ply:ConCommand("say !nortv 1")

        print("Auto Homigrad Setup Initialized!")
        ply:ChatPrint("Auto Homigrad Setup Initialized!")
    end)
end


hook.Add("PlayerInitialSpawn", "ConstructSetupAuto", function(ply)
    DoConstructSetup(ply, false)
end)

concommand.Add("construct_setup", function(ply, cmd, args)
    DoConstructSetup(ply, true)
end)


