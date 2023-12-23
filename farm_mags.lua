-- by bocho#8180
-- Farms all magplants and anti dc

local magplant_table = {} -- format: magplant_table = {{x1, y2}, {x2, y2}, ...}

local mag_is_empty, grab_remote, joined_world, on_world = false, false, false, true

local player = {
    pos_x = 0, pos_y = 0,
    world_name = ""
}

if player.world_name == "" then
    player.world_name = GetLocal().world
end

if player.pos_x == 0 and player.pos_y == 0 then
    player.pos_x = GetLocal().pos_x / 32
    player.pos_y = GetLocal().pos_y / 32
end

local function WARN(text) -- Client sided /warn packet
	local packet = {
		[0] = "OnAddNotification",
		[1] = "",
		[2] = text,
		[3] = '',
		[4] = 0,
		netid = -1
	}
	SendVarlist(packet)
end

function is_around_player(x, y, rad_x, rad_y)
    local lp = GetLocal()
    local lp_x, lp_y = lp.tile_x, lp.tile_y
    rad_x = rad_x or 2
    rad_y = rad_y or 2
    return lp_x - rad_x < x and lp_y - rad_y < y and lp_x + rad_x > x and lp_y + rad_y > y
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

function count(id)
    local count = 0
    for _, inv in pairs(GetInventory()) do
       if inv.id == id then
          count = count + inv.count
       end
    end
    return count
end

function get_remote(x, y)
    pkt_punch(x, y, 32)
    SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|".. x .."|\ny|" .. y .. "|\nbuttonClicked|getRemote")
end

function main()

    if #magplant_table == 0 then
        for _,tile in pairs(GetTiles()) do
            if tile.fg == 5638 and is_around_player(tile.pos_x, tile.pos_y + 256, 3, 2) then
                table.insert(magplant_table, {tile.pos_x, tile.pos_y + 256})
            end
        end
    end

    if not is_around_player(table.unpack(magplant_table[1])) then
        FindPath(magplant_table[1][1], magplant_table[1][2] - 1)
    end

    get_remote(table.unpack(magplant_table[1]))

    Sleep(500)

    SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|1\ncheck_bfg|1\ncheck_autospam|0\ncheck_autopull|0\ncheck_autoplace|0\ncheck_antibounce|0\ncheck_modfly|0\ncheck_speed|0\ncheck_gravity|0\ncheck_lonely|0\ncheck_fastdrop|0\ncheck_gems|1\ncheck_ignoreo|0")

    --WARN("Starting...")

    local i = 1

    --log(#magplant_table)

    while i <= #magplant_table do

        if i >= #magplant_table then
            WARN("Finished farming mags")
            SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|0\ncheck_bfg|0\ncheck_autospam|0\ncheck_autopull|0\ncheck_autoplace|0\ncheck_antibounce|0\ncheck_modfly|0\ncheck_speed|0\ncheck_gravity|0\ncheck_lonely|0\ncheck_fastdrop|0\ncheck_gems|1\ncheck_ignoreo|0")
            break;
        end

        if player.world_name ~= GetLocal().world then
            on_world = false
        end

        if not on_world and player.world_name == GetLocal().world then
            joined_world = true
            on_world = true
        end

        if joined_world then
            joined_world = false
            Sleep(6000)
            FindPath(player.pos_x, player.pos_y)
            Sleep(500)
            SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|".. magplant_table[i][1] .."|\ny|" .. magplant_table[i][2] .. "|\nbuttonClicked|getRemote")
            Sleep(500)
            SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|1\ncheck_bfg|1\ncheck_gems|1")
            Sleep(500)
            grab_remote = true
        end

        if mag_is_empty then
            i = i + 1
            if not is_around_player(table.unpack(magplant_table[i])) then
                FindPath(magplant_table[i][1], magplant_table[i][2] - 1)
            end
            WARN(string.format("Magplant #%d is empty, moving to #%d", i - 1, i))
            mag_is_empty = false
            grab_remote = true
            Sleep(500)
        end

        if grab_remote then
            if not is_around_player(table.unpack(magplant_table[i])) then
                FindPath(magplant_table[i][1], magplant_table[i][2] - 1)
            end
            get_remote(table.unpack(magplant_table[i]))
            Sleep(500)
            grab_remote = false
            Sleep(500)
        end

        Sleep(1000)

    end

    RemoveCallback("farm_mags_varlist")
    RemoveCallback("farm_mags_packets")

end

AddCallback("farm_mags_varlist", "OnVarlist", function(varlist, packet)

    if varlist[0]:find("OnDialogRequest") then
        if varlist[1]:find("The machine is currently empty") then
            mag_is_empty = true
        end

        if varlist[1]:find("MAGPLANT 5000") then
            return true
        end

    end

    if varlist[0]:find("OnTalkBubble") then
        if varlist[1] == GetLocal().netid and varlist[2]:find("The MAGPLANT 5000 is empty") and not grab_remote then
            mag_is_empty = true
        end
    end

end)

AddCallback("farm_mags_packets", "OnPacket", function(type, packet)
    if packet:find("action|join_request") then
        if packet:find("name|" .. player.world_name) then
            joined_world = true
        end
    end
end)

main()