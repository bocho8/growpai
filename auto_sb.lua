local sb_text = "`0REME MIN `11 DL `0AT `a[`1REMEBOC`a] `2#NEEDADMIN #TRUSTED #ALWAYS SB #ACC 5BGL"

local do_sb = false

SendPacket(2, "action|input\n|text|/sb " .. sb_text)

AddCallback("auto_sb", "OnVarlist", function(varlist, packet)
    
    if varlist[0]:find("OnConsoleMessage") and varlist[1]:find("You can annoy with broadcasts again!") then
        Sleep(500)
        do_sb = true
    end

end)

while true do
    if do_sb then
        do_sb = false
        SendPacket(2, "action|input\n|text|/sb " .. sb_text)
    end

    Sleep(200)
end