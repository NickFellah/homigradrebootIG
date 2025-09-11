bombdefuse.ragdolls = {}
function bombdefuse.StartRoundSV()
	tdm.RemoveItems()

	roundTimeStart = CurTime()
	roundTime = 60 * (2 + math.min(#player.GetAll() / 8,2))

	tdm.DirectOtherTeam(3,1,2)

	OpposingAllTeam()
	AutoBalanceTwoTeam()

	local spawnsT,spawnsCT = css.SpawnsTwoCommand()
	tdm.SpawnCommand(team.GetPlayers(1),spawnsT)
	tdm.SpawnCommand(team.GetPlayers(2),spawnsCT)
	bombdefuse.ragdolls = {}

	tdm.CenterInit()
end

function bombdefuse.RoundEndCheck()

	if roundTimeStart + roundTime - CurTime() <= 0 then EndRound() end
	
	local TAlive = tdm.GetCountLive(team.GetPlayers(1))
	local CTAlive = tdm.GetCountLive(team.GetPlayers(2))

	if TAlive == 0 and CTAlive == 0 then EndRound() return end

	if TAlive == 0 then EndRound(2) end
	if CTAlive == 0 then EndRound(1) end

	tdm.Center()
end

function bombdefuse.EndRound(winner) tdm.EndRoundMessage(winner) end

function bombdefuse.PlayerInitialSpawn(ply) ply:SetTeam(math.random(1,2)) end

function bombdefuse.PlayerSpawn2(ply,teamID)
	local teamTbl = css[css.teamEncoder[teamID]]
	local color = teamTbl[2]
	ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])
    ply:SetPlayerColor(color:ToVector())

	if ply:IsUserGroup("sponsor") or ply:IsUserGroup("supporterplus") then
		ply:Give("weapon_vape")
	end

	for i,weapon in pairs(teamTbl.weapons) do ply:Give(weapon) end

	tdm.GiveSwep(ply,teamTbl.main_weapon)
	tdm.GiveSwep(ply,teamTbl.secondary_weapon)
end

function bombdefuse.PlayerCanJoinTeam(ply,teamID)
    if teamID == 3 then ply:ChatPrint("Not Right Now.") return false end
end

function bombdefuse.ShouldSpawnLoot() return false end

function bombdefuse.PlayerDeath(ply,inf,att)
    bombdefuse.ragdolls[ply:GetNWEntity("Ragdoll")] = true
    return false
end