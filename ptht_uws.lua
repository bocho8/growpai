--[[

    Made by bocho#8180
    do /start to start the cycles
    use ghost and anti dc cps

]]

local local_world = {
    size_x = 0,
    size_y = 0,
    name = ""
}

local mag_seeds = {x, y}
local mag_blocks = {x, y}
local break_pos = {x, y}

local start = false

local function GET_CMD(packet)
    return packet:gsub("action|input\n|text|/", "")
end

local function GET_CMD_ARGS(packet, command)
    return packet:gsub("action|input\n|text|/" .. command, "")
end

local function is_in_world()
    return GetLocal().world ~= "EXIT"
end

local function set_world_size()

    if local_world.size_x ~= 0 and local_world.size_y ~= 0 then
        return
    end

    local x, y = {}, {}

    if not is_in_world() then
        local_world.size_x = 0
        local_world.size_y = 0
        return
    end
    
    for _, tile in pairs(GetTiles()) do
        table.insert(x, tile.pos_x)
        table.insert(y, tile.pos_y)
    end

    if math.max(table.unpack(x)) >= 127 or math.max(table.unpack(y)) >= 127 then
        local_world.size_x = 199
        local_world.size_y = 199
    else
        local_world.size_x = math.max(table.unpack(x))
        local_world.size_y = math.max(table.unpack(y))
    end

end

local function count(id)
    local c = 0
    for _, inv in pairs(GetInventory()) do
       if inv.id == id then
          c = c + inv.count
       end
    end
    return c
end

local function pkt_punch(x, y, id)
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

function check_remote()

    if count(5640) < 1 then
        FindPath(mag_seeds.x, mag_seeds.y - 1)
        pkt_punch(x, y, 32)
        SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|".. mag_seeds.x .."|\ny|" .. mag_seeds.y .. "|\nbuttonClicked|getRemote")
    end

    return count(5640) >= 1
end

local function on_dialog(str)
    SendVarlist({
        [0] = "OnDialogRequest",
        [1] = "set_default_color|`o\nadd_label_with_icon|big|`1PTHT UWS `abocho#8180 ``|left|12600|\nadd_textbox|" .. str .. "|\nend_dialog|||Continue|",
        netid = -1
    })
end

local function plant()

    local stop = false

    AddCallback("plant", "OnVarlist", function(varlist, packet)
        if varlist[0] == "OnTalkBubble" then
            if varlist[2] == "The MAGPLANT 5000 is empty." then
                stop = true
            end
        end

        if varlist[0] == "OnDialogRequest" then
            return true
        end

    end)

    local x_increment, x_max, x_start

    log("Planting")

    for y = local_world.size_y, 0, -1 do
       x_increment = 6
       x_max = local_world.size_x
       x_start = 0

       if y % 4 >= 2 then
          x_increment = -6
          x_max = 0
          x_start = local_world.size_x
       end

       for x = x_start, x_max, x_increment do

        if stop == true then
            log("Stopping...")
            return false
        end

        while local_world.name ~= GetLocal().world do
            log("Waiting for reconnect...")
            Sleep(15000)
        end

        if not check_remote() then
            log("Getting remote...")
        end

        if GetTile(x, y).fg == 0 and GetTile(x, y + 1).fg ~= 0 and not GetIteminfo(GetTile(x, y + 1).fg).name:find("Seed") and not GetIteminfo(GetTile(x, y + 1).fg).name:find("Plant") then
           FindPath(x, y)
           Sleep(20)
           x_offset = -3
           while x_offset < 3 do
              if GetTile(x + x_offset, y).fg == 0 and GetTile(x + x_offset, y + 1).fg ~= 0 and not GetIteminfo(GetTile(x + x_offset, y + 1).fg).name:find("Seed") and not GetIteminfo(GetTile(x + x_offset, y + 1).fg).name:find("Plant")then
                 pkt_punch(x + x_offset, y, 5640)
                 Sleep(90)
              end
              x_offset = x_offset + 1
           end
        end
       end
    end

    for y = local_world.size_y, 0, -1 do

        x_increment = 1
        x_max = local_world.size_x
        x_start = 0

        if y % 4 >= 2 then
            x_increment = -1
            x_max = 0
            x_start = local_world.size_x
        end

        for x = x_start, x_max, x_increment do

            if stop == true then
                log("Stopping...")
                return false
            end

            while local_world.name ~= GetLocal().world do
                log("Waiting for reconnect...")
                Sleep(5000)
            end

            if GetTile(x, y).fg == 0 and GetTile(x, y + 1).fg ~= 0 and not GetIteminfo(GetTile(x, y + 1).fg).name:find("Seed") and not GetIteminfo(GetTile(x, y + 1).fg).name:find("Plant") then
                FindPath(x, y)
                Sleep(60)
                pkt_punch(x, y, 5640)
                Sleep(130)
            end

        end
    end

    RemoveCallback("plant")

    return true

end

local function harvest()

    log("Harvesting")

    local x_increment, x_max, x_start

    for y = local_world.size_y, 0, -1 do

        x_increment = 1
        x_max = local_world.size_x
        x_start = 0

        if y % 4 >= 2 then
            x_increment = -1
            x_max = 0
            x_start = local_world.size_x
        end

        for x = x_start, x_max, x_increment do

            while local_world.name ~= GetLocal().world do
                log("Waiting for reconnect...")
                Sleep(5000)
            end

            if GetTile(x, y).ready and GetIteminfo(GetTile(x, y).fg).growth > 0 then
                FindPath(x, y)
                Sleep(60)
                pkt_punch(x, y, 18)
                Sleep(130)
            end

        end
    end

    return true

end

local function do_uws()
    log("UWS")
    SendPacket(2, "action|dialog_return\ndialog_name|ultraworldspray")
end

function main()

    set_world_size()
    if local_world.name == "" then
        local_world.name = GetLocal().world
    end

    AddCallback("ptht", "OnPacket", function(type, packet)
        if packet:find("action|input") then
            if GET_CMD(packet) == "start" then
                --SendPacket(2, "action|input\n|text|/ghost")
                EditToggle("ModFly", true)
                start = true
            end
        end
    end)

    if mag_seeds.x == nil or mag_seeds.y == nil then
        on_dialog("Wrench MAGPLANT 500 (seeds)")
        AddCallback("mag_seeds", "OnVarlist", function(varlist, packet)
            if varlist[0]:find("OnDialogRequest") then
                if varlist[1]:find("MAGPLANT 5000") then
                    mag_seeds.x = varlist[1]:match('embed_data|x|(%d+)')
                    mag_seeds.y = varlist[1]:match('embed_data|y|(%d+)')
                    return true
                end
            end
        end)

        while mag_seeds.x == nil or mag_seeds.y == nil do
            Sleep(50)
        end

        on_dialog(string.format("Got MAGPLANT 500 at `2(%d, %d)", mag_seeds.x, mag_seeds.y))

        RemoveCallback("mag_seeds")
    end

    while true do
        
        Sleep(200)

        if GetItemCount(12600) < 1 then
            log("No more UWS")
            break;
        end

        while local_world.name ~= GetLocal().world do
            send_console_msg("Waiting for reconnect...")
            Sleep(15000)
        end

        if start then

            for _,tile in pairs(GetTiles()) do
                if tile.ready and GetIteminfo(tile.fg).growth > 0 then
                    harvest()
                end
            end
            
            if not plant() then
                log("No more Seeds")
                break;
            end
            Sleep(1000)
    
            do_uws()
            Sleep(5000)
    
            harvest()
            Sleep(500)
            for _,tile in pairs(GetTiles()) do
                if tile.ready and GetIteminfo(tile.fg).growth > 0 then
                    harvest()
                end
            end
        end

    end

    on_dialog("Finished")

end

main()