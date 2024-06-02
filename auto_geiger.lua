--[[

    Made by bocho3001
    Made for CPS

]]

local ping_crystal = true
local webhook_url = "https://discord.com/api/webhooks/1246919075532374077/nn74mrqe0sAn65hhFiIgjLRy4_0J_m6-MhM98UEvsUEYZFVhLfOalV70Q9UdbRhudyss"

---------------------------------------------------------------

local previousTime = nil
local delay = 5.0
local prev_pos = {x = 0, y = 0}
local stuck_check = 0

function send_console_msg(str)
    SendVarlist({
        [0] = "OnConsoleMessage",
        [1] = "`a[`1Auto Geiger`a]`0 " .. str,
        netid = -1
    })
end

send_console_msg("Script by bocho3001")

-- Callback for incoming raw packets to update delay
function OnIncomingRawPacket(packet)
    if packet.type == 17 then
        local currentTime = os.time()
        if previousTime then
            delay = os.difftime(currentTime, previousTime)
        end
        previousTime = currentTime
    end
end

AddCallback("AutoGeiger", "OnIncomingRawPacket", OnIncomingRawPacket)

-- Function to search the grid for the Geiger item
function searchGrid()
    local lp = GetLocal()
    local newX = lp.pos_x + math.random(3, 7)
    local newY = lp.pos_y + math.random(3, 7)
    
    newX = newX % 30
    newY = newY % 30
    
    FindPath(newX, newY)
    Sleep(5000)

    if prev_pos.x == lp.pos_x and prev_pos.y == lp.pos_y then
        stuck_check = stuck_check + 1
    else
        stuck_check = 0
    end

    if stuck_check >= 5 then
        FindPath(15, 15)
        stuck_check = 0
    end

    prev_pos.x = lp.pos_x
    prev_pos.y = lp.pos_y
end

-- Function to search for the Geiger item within a specific radius
function searchGeiger(x, y)
    local delay_checks = 0
    for i = -3, 3, 3 do
        for j = -3, 3, 3 do
            if delay <= 1.0 then
                Sleep(5000)
            end
            if delay >= 4.0 then
                delay_checks = delay_checks + 1
                if delay_checks > 4 then
                    return false
                end
            end
            FindPath(x + i, y + j)
            Sleep(3000)
        end
    end
    return true
end

function removeBacktickAndChar(str)
    local result = ""
    local index = 1
    while index <= #str do
        local backtickIndex = string.find(str, "`", index)
        if backtickIndex then
            result = result .. string.sub(str, index, backtickIndex - 1)
            index = backtickIndex + 2
        else
            result = result .. string.sub(str, index)
            break
        end
    end
    return result
end

function webhook(varlist, packet)
    if varlist[0] == "OnConsoleMessage" and varlist[1]:find("Given") then
        local message = ([[
        {
            "content": null,
            "embeds": [
                {
                    "title": "Found Geiger item!",
                    "description": "%s\nTime: %s%s",
                    "color": 5814783
                }
            ],
            "attachments": []
        }
        ]]):format(removeBacktickAndChar(varlist[1]), tostring(os.date('%d/%m/%Y at %I:%M:%S %p')), ping_crystal and (varlist[1]:find("Crystal") and "\n@everyone" or "") or "")
        SendWebhook(webhook_url, message)
    end
end

AddCallback("AutoGeiger_Webhook", "OnVarlist", webhook)

function mainLoop()
    local lp = GetLocal()
    if delay <= 2.0 then
        searchGeiger(lp.pos_x / 32, lp.pos_y / 32)
    end

    if delay >= 4.0 then
        searchGrid()
    end
end

SendWebhook(webhook_url, ([[
    {
        "content": null,
        "embeds": [
            {
                "title": "Started Auto Geiger!",
                "description": "Time: %s",
                "color": 5814783
            }
        ],
        "attachments": []
    }
]]):format(tostring(os.date('%d/%m/%Y at %I:%M:%S %p'))))

while true do
    Sleep(100)
    mainLoop()
end