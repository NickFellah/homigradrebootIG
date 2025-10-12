include("../../playermodelmanager_sv.lua")

local function makeT(ply)
    ply.roleT = true
    table.insert(kingkong.t,ply)
end

function kingkong.SpawnsCT()
    local aviable = {}

    for i,point in pairs(ReadDataMap("spawnpointshiders")) do
        table.insert(aviable,point)
    end

    return aviable
end

function kingkong.SpawnsT()
    local aviable = {}

    for i,point in pairs(ReadDataMap("spawnpointswick")) do
        table.insert(aviable,point)
    end

    return aviable
end

function kingkong.StartRoundSV()
    tdm.RemoveItems()
    tdm.DirectOtherTeam(2,1,1)

	roundTimeStart = CurTime()
	roundTime = math.max(math.ceil(#player.GetAll() / 1.5),1) * 90

    roundTimeLoot = 5

    for i,ply in pairs(team.GetPlayers(2)) do ply:SetTeam(1) end
    for i,ply in player.Iterator() do ply.roleT = false end

    kingkong.t = {}

    local countT = 0

    local aviable = kingkong.SpawnsCT()
    local aviable2 = kingkong.SpawnsT()

    local players = PlayersInGame()

    local count = 1
    for i = 1,count do
        local ply = table.Random(players)
        table.RemoveByValue(players,ply)

        makeT(ply)
    end

    kingkong.SyncRole()

    tdm.SpawnCommand(players,aviable,function(ply)
        ply.roleT = false

        ply:Give("weapon_gurkha")
        local wep = ply:Give("weapon_hk_usp")
        wep:SetClip1(wep:GetMaxClip1())
        ply:GiveAmmo(2 * wep:GetMaxClip1(),wep:GetPrimaryAmmoType())

        if math.random(1,8) == 8 then ply:Give("adrenaline") end
        if math.random(1,7) == 7 then ply:Give("painkiller") end
        if math.random(1,6) == 6 then ply:Give("medkit") end
        if math.random(1,5) == 5 then ply:Give("med_band_big") end
        if math.random(1,8) == 8 then ply:Give("morphine") end
    end)

    local kingkongs = team.GetPlayers(1)
	local kingkongSpawns = {}

	for _, kingkong in ipairs(kingkongs) do
		if IsValid(kingkong) then
			kingkongSpawns[kingkong] = kingkong:GetPos()
			kingkong:SetPos(Vector(0, 0, -99999))
			kingkong:SetNWBool("kingkongBlind", true)
			kingkong:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 1, 15)
			kingkong:ConCommand("hg_subtitle 'You will be released in 10 seconds...', red")
			kingkong:ChatPrint("You will be released in 10 seconds...")
		end
	end
	
	timer.Simple(15, function()
		if roundActiveName ~= "kingkong" then return end

		for _, kingkong in ipairs(kingkongs) do
			if IsValid(kingkong) then
				local pos = kingkongSpawns[kingkong]
				if pos then kingkong:SetPos(pos) end
				kingkong:SetNWBool("SeekerBlind", false)
				kingkong:ScreenFade(SCREENFADE.PURGE, Color(0, 0, 0, 0), 1, 0)
				kingkong:ConCommand("hg_subtitle 'Go! Hunt down those Explorers!', green")
			end
		end

		for _, ply in ipairs(team.GetPlayers(2)) do
			if IsValid(ply) then
				ply:ConCommand("hg_subtitle 'Kingkong is now released! No Point In Running!', red")
			end
		end
	end)

    tdm.SpawnCommand(kingkong.t,aviable2,function(ply)
        timer.Simple(1,function()
            ply.nopain = true
        end)
    end)

    tdm.CenterInit()

    return {roundTimeLoot = roundTimeLoot}
end

local aviable = ReadDataMap("spawnpointsct")

function kingkong.RoundEndCheck()
    tdm.Center()

    if roundTimeStart + roundTime - CurTime() <= 0 then EndRound() end
	local TAlive = tdm.GetCountLive(kingkong.t)
	local Alive = tdm.GetCountLive(team.GetPlayers(1),function(ply) if ply.roleT or ply.isContr then return false end end)

    if roundTimeStart + roundTime < CurTime() then
        EndRound()
	end

	if TAlive == 0 and Alive == 0 then EndRound() return end

	if TAlive == 0 then EndRound(2) end
	if Alive == 0 then EndRound(1) end
end

function kingkong.EndRound(winner)
    PrintMessage(3,(winner == 1 and "No Remaining Survivors Left! KingKong Wins." or winner == 2 and "KingKong Was Defeated! Survivors Win." or "Time! Survivors Wins."))
end

util.AddNetworkString("PlayerActivatedRage")

-- this code is very bad, i have no idea what i thinking, and am very sorry.
-- future gamemodes are 100% going to be better and not as messy/ass as this

-- whanga

hook.Add("PlayerButtonDown", "CheckKeyPress", function(ply, button)
    if ply:GetModel() == "models/vedatys/orangutan.mdl" and button == KEY_R and roundActiveName == "kingkong" and ply:Alive() then
        if ply.abilityTimer == true then ply:ConCommand("hg_Subtitle 'Please Wait For The Cooldown. Default: 20', red") return end
        -- activate the king kong ability
        ply.abilityTimer = true
        ply:ConCommand("hg_Subtitle 'ACTIVATED RAGE!', green")
        ply:ConCommand("act zombie")
        ply.adrenaline = ply.adrenaline + 1

        ply:EmitSound("ambient/creatures/town_child_scream1.wav", 100, 90, 1)

        net.Start("PlayerActivatedRage")
        net.Send(ply)
            
        timer.Simple(20, function()
            if ply:GetModel() == "models/vedatys/orangutan.mdl" and roundActiveName == "kingkong" then -- fuck me
                ply.abilityTimer = false
                ply:ConCommand("hg_Subtitle 'Press R To Activate Rage', green")
                --draw.DrawText( "Press R To Activate Rage", "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, red, TEXT_ALIGN_CENTER )
            end
        end)
    end
end)

local empty = {}

function kingkong.PlayerSpawn2(ply,teamID)
    local teamTbl = kingkong[kingkong.teamEncoder[teamID]]
    local color = teamID == 1 and Color(math.random(55,165),math.random(55,165),math.random(55,165)) or teamTbl[2]

    if ply.roleT then
        ply:Give("weapon_kingkong")
        ply:Give("megamedkit")
        ply:Give("med_band_big")
        ply:Give("med_band_small")

        ply.nopain = true
        ply.stamina = 50000
        ply.Blood = 500000
        ply.adrenaline = ply.adrenaline + 1

        ply.abilityTimer = false
        
        ply:SetModel("models/vedatys/orangutan.mdl")
    else
        local customModel = GetPlayerModelBySteamID(ply:SteamID())

        if customModel then
            ply:SetSubMaterial()
            ply:SetModel(customModel)
        else
            ply:SetModel(tdm.models[math.random(#tdm.models)])
        end

        if ply:GetModel() == "models/vedatys/orangutan.mdl" then
            ply:SetModel(tdm.models[math.random(#tdm.models)])
        end

        EasyAppearance.SetAppearance( ply )
    end

    ply:SetPlayerColor(color:ToVector())
    
    if ply.roleT == false then
        ply:Give("weapon_hands")
     else
        ply:StripWeapon("weapon_hands")
    end
    timer.Simple(0,function() ply.allowFlashlights = true end)
end

function kingkong.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
end

function kingkong.PlayerCanJoinTeam(ply,teamID)
    if ply:IsAdmin() then
        if teamID == 2 then ply.forceCT = nil ply.forceT = true ply:ChatPrint("You Will Be Traitor Next Round.") return false end
        if teamID == 3 then ply.forceT = nil ply.forceCT = true ply:ChatPrint("You Will Be Innocent Next Round") return false end
    else
        if teamID == 2 or teamID == 3 then ply:ChatPrint("Not Right Now.") return false end
    end

    return true
end

util.AddNetworkString("homicide_roleget2")

function kingkong.SyncRole()
    local role = {{},{}}

    for i,ply in pairs(team.GetPlayers(1)) do
        if ply.roleT then table.insert(role[1],ply) end
    end

    net.Start("homicide_roleget2")
    net.WriteTable(role)
    net.Broadcast()
end

function kingkong.PlayerDeath(ply,inf,att)
    if roundActiveName ~= "kingkong" or ply.roleT == true then return end
    PrintMessage(3, ply:GetName().. " Has Fallen...")

    return false 
end

local common = {"food_lays","weapon_pipe","weapon_bat","med_band_big","med_band_small","medkit","food_monster","food_fishcan","food_spongebob_home"}
local uncommon = {"medkit","weapon_hammer","painkiller"}
local rare = {"weapon_fiveseven","weapon_gurkha","weapon_t","weapon_pepperspray","*ammo*"}

function kingkong.ShouldSpawnLoot()
    return true
end

function kingkong.GuiltLogic(ply,att,dmgInfo)
    return ply.roleT == att.roleT and 5 or 0
end

kingkong.NoSelectRandom = true
