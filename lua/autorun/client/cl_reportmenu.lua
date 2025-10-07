local predefinedReasons = {
    "Exploiting",
    "Glitch Abusing",
    "Harassment",
    "Mic/Chat Spam",
    "RDM",
    "Other"
}

local cooldown = false

local function OpenReportMenu()
    if cooldown then
        chat.AddText(Color(255, 0, 0), "[Report] You must wait before sending another report!")
        return
    end

    local frame = vgui.Create("DFrame")
    frame:SetTitle("Report a Player")
    frame:SetSize(450, 450)
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(true)

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetSize(200, 340)
    scroll:SetPos(10, 30)

    local selectedPlayer = nil

    for _, ply in ipairs(player.GetAll()) do
        local btn = vgui.Create("DButton", scroll)
        btn:SetTall(50)
        btn:Dock(TOP)
        btn:DockMargin(0, 0, 0, 5)
        btn:SetText("")

        local avatar = vgui.Create("AvatarImage", btn)
        avatar:SetSize(40, 40)
        avatar:SetPlayer(ply, 64)
        avatar:SetPos(5, 5)

        local nameLabel = vgui.Create("DLabel", btn)
        nameLabel:SetText(ply:Nick())
        nameLabel:SetFont("DermaDefaultBold")
        nameLabel:SetPos(55, 17)
        nameLabel:SizeToContents()

        btn.DoClick = function()
            selectedPlayer = ply
            surface.PlaySound("buttons/button14.wav")
        end

        btn.Paint = function(self, w, h)
            if selectedPlayer == ply then
                draw.RoundedBox(6, 0, 0, w, h, Color(50, 150, 255, 120))
            else
                draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 40, 180))
            end
        end
    end

    local reasonLabel = vgui.Create("DLabel", frame)
    reasonLabel:SetText("Select Reason:")
    reasonLabel:SetPos(220, 40)
    reasonLabel:SizeToContents()

    local reasonCombo = vgui.Create("DComboBox", frame)
    reasonCombo:SetPos(220, 60)
    reasonCombo:SetSize(210, 25)

    for _, reason in ipairs(predefinedReasons) do
        reasonCombo:AddChoice(reason)
    end

    local customReason = vgui.Create("DTextEntry", frame)
    customReason:SetPos(220, 100)
    customReason:SetSize(210, 200)
    customReason:SetMultiline(true)
    customReason:SetPlaceholderText("Add extra details or describe what happened...")

    local submit = vgui.Create("DButton", frame)
    submit:SetText("Submit Report")
    submit:SetPos(220, 320)
    submit:SetSize(210, 40)

    submit.DoClick = function()
        if not IsValid(selectedPlayer) then
            chat.AddText(Color(255, 0, 0), "[Report] Please select a player to report.")
            return
        end

        local reason = reasonCombo:GetSelected() or "No reason selected"
        local details = customReason:GetValue()

        net.Start("SendPlayerReport")
        net.WriteEntity(selectedPlayer)
        net.WriteString(reason)
        net.WriteString(details)
        net.SendToServer()

        cooldown = true
        timer.Simple(30, function() cooldown = false end)

        frame:Close()
    end
end

hook.Add("PlayerButtonDown", "ReportMenuKey", function(ply, key)
    if key == KEY_F3 then
        OpenReportMenu()
    end
end)

concommand.Add("open_report_menu", OpenReportMenu)