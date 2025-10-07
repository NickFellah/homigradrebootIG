util.AddNetworkString("SendPlayerReport")

local function GetSteamAvatar(steamid, callback)
    local steam64 = util.SteamIDTo64(steamid)
    local avatarURL = "https://avatars.steamstatic.com/" .. steam64 .. "_full.jpg"
    callback(avatarURL)
end

net.Receive("SendPlayerReport", function(len, ply)
    local target = net.ReadEntity()
    local reason = net.ReadString()
    local details = net.ReadString()

    if not IsValid(ply) or not IsValid(target) or reason == "No reason selected" then ply:ConCommand("hg_subtitle [Report] No Reason Selected., red") return end

    local reportData = {
        reporterName = ply:Nick(),
        reporterSteamID = ply:SteamID(),
        targetName = target:Nick(),
        targetSteamID = target:SteamID(),
        reason = reason,
        details = details ~= "" and details or "None",
        time = os.date("%Y-%m-%d %H:%M:%S")
    }

    local formatted = string.format([[
-----------------------------
 HOMIGRAD REPORT

 Reporter: %s [%s]
 Target: %s [%s]

 Reason: %s
 Details: %s
-----------------------------
]], reportData.reporterName, reportData.reporterSteamID,
    reportData.targetName, reportData.targetSteamID,
    reportData.reason, reportData.details)

    for _, admin in ipairs(player.GetAll()) do
        if admin:IsAdmin() then
            admin:ChatPrint(reportData.reporterName .. " reported " .. reportData.targetName .. " for: " .. reportData.reason .. ". Check the Discord for more info.")
        end
    end

    ply:ConCommand("hg_subtitle [Report] Your report has been submitted., green")

    GetSteamAvatar(reportData.targetSteamID, function(avatarURL)
        local embed = {
            username = "Homigrad Reports",
            avatar_url = "https://cdn.discordapp.com/icons/123456789012345678/abcdef1234567890.webp?size=1024",
            embeds = {{
                title = "🚨 Player Report",
                color = 16733440,
                thumbnail = { url = avatarURL },
                fields = {
                    { name = "👤 Reporter", value = string.format("%s\n`%s`", reportData.reporterName, reportData.reporterSteamID), inline = true },
                    { name = "🎯 Target", value = string.format("%s\n`%s`", reportData.targetName, reportData.targetSteamID), inline = true },
                    { name = "🪓 Reason", value = reportData.reason, inline = false },
                    { name = "📝 Details", value = reportData.details, inline = false }
                },
                footer = { text = "Reported at " .. reportData.time }
            }}
        }

        http.Post("https://discord.com/api/webhooks/1424970096580759562/aBMireqhsOkeQgNEyiP8g3GmmqyZyz-MtQQ6NuMSb87kJ7KePiAVNzCrAQmP0jpnUwdl", {
            payload_json = util.TableToJSON(embed)
        })
    end)
end)
