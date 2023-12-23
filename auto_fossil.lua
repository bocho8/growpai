local function DOUBLE_CLICK_ITEM(ITEM_ID) -- Send a double click item packet, mostly used for converting World Locks to Diamond Locks
    local packet = {
        type = 10,
        int_data = ITEM_ID
    }

    SendPacketRaw(packet)
end

function pkt_punch(x, y, id)
    local lp = GetLocal()
    local packet = {
      type = 3,
      int_data = id,
      pos_x = lp.pos_x,
      pos_y = lp.pos_y,
      int_x = x,
      int_y = y,
    }
   SendPacketRaw(packet)
end

local ROCK_HAMMER_ID = 3932

function count(id)
    local count = 0
    for _, inv in pairs(GetInventory()) do
       if inv.id == id then
          count = count + inv.count
       end
    end
    return count
end

local stop = false

local punch_count = 0

function main()

    if count(ROCK_HAMMER_ID) < 1 then
        RemoveCallback("auto_fossil")
        return true;
    end

    --DOUBLE_CLICK_ITEM(ROCK_HAMMER_ID)

    while true do
        
        if stop then
            RemoveCallback("auto_fossil")
            return true;
        end

        pkt_punch(GetLocal().tile_x, GetLocal().tile_y + 1, 18)

        punch_count = punch_count + 1

        if punch_count >= 9 then
            punch_count = 0
            Sleep(5000)
        end

        Sleep(350)

    end
    
end

function hook(varlist, packet)

    if varlist[0] == "OnTalkBubble" then
        if varlist[1] == GetLocal().netid and varlist[2]:find("I unearthed a Fossil!") then
            stop = true
        end
    end

end

AddCallback("auto_fossil", "OnVarlist", hook)

main()