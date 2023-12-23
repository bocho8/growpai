--[[

    Made by bocho#8180
    Made for Growtopia CPS

]]

local params = {
    delay = 0, -- no need to change
}

--------------------------------------------------------------------

local local_world = {
    size_x = 200,
    size_y = 200,
    name = ""
}

function send_console_msg(str)
    SendVarlist({
        [0] = "OnConsoleMessage",
        [1] = "`a[`1Farm Helper`a]`0 " .. str,
        netid = -1
    })
end

send_console_msg("Lua made by bocho#8180")
send_console_msg("Do `^/farm help `0for commands")

function is_in_world()
    return GetLocal().world ~= "EXIT"
end

function set_world_size()
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

set_world_size()

--log(local_world.size_x .. ", " .. local_world.size_y)


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

local mag = {
    x, y
}

function inv_count(id)
    local count = 0
    for _, inv in pairs(GetInventory()) do
       if inv.id == id then
          count = count + inv.count
       end
    end
    return count
end

function check_remote()

    
    if inv_count(5640) < 1 then
        if mag.x == nil or mag.y == nil then
            send_console_msg("Wrench Magplant and Update it")
            return false
        end
        FindPath(mag.x, mag.y - 1)
        pkt_punch(mag.x, mag.y, 32)
        SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|".. mag.x .."|\ny|" .. mag.y .. "|\nbuttonClicked|getRemote")
    end


    return inv_count(5640) >= 1
end

--#region harvest

local harvest = {
    enabled = false,
}

function do_harvest()

    if not is_in_world() then
        send_console_msg("Enter a world")
        return
    end

    local_world.name = GetLocal().world

    send_console_msg("Started Harvest")

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

            if not harvest.enabled then
                return
            end
    
            if local_world.name ~= GetLocal().world then
                send_console_msg("Stopped Harvesting: exit world: " .. GetLocal().world .. ", " .. local_world.name)
                return
            end
    
            if GetTile(x, y).ready and GetIteminfo(GetTile(x, y).fg).growth > 0 then
                FindPath(x, y)
                Sleep(params.delay + 60)
                pkt_punch(x, y, 18)
                Sleep(params.delay + 130)
            end

        end
    end

    harvest.enabled = false

    if harvest.enabled == false then
        send_console_msg("Finished Harvesting.")
    end

end

--#endregion

--#region plant

local plant = {
    enabled = false,
    plant_id = 0,
}

function do_plant()

    if not is_in_world() then
        send_console_msg("Enter a world")
        return
    end

    local_world.name = GetLocal().world

    if not check_remote() then
        send_console_msg("Wrench Magplant and Get Remote.")
        return
    end

    send_console_msg("Started Planting")

    EditToggle("ModFly", true)

    --SendPacket(2, "action|input\n|text|/ghost")

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

            if not plant.enabled then
                send_console_msg("Stopped Planting.")
                return
            end
    
            if local_world.name ~= GetLocal().world then
                send_console_msg("Stopped Planting: exit world: " .. GetLocal().world .. ", " .. local_world.name)
                return
            end
    
            if GetTile(x, y).fg == 0 and GetTile(x, y + 1).fg ~= 0 and not (x == 0 or x == local_world.size_x) --[[and GetIteminfo(GetTile(x, y + 1).fg).name:find("Platform") or GetIteminfo(GetTile(x, y + 1).fg).name:find("Waterslide Strut")]] then
                FindPath(x, y)
                Sleep(params.delay + 40)
                pkt_punch(x, y, 5640)
                Sleep(params.delay + 120)
            end

        end
    end

    plant.enabled = false

    if plant.enabled == false then
        send_console_msg("Finished Planting.")
    end

    --SendPacket(2, "action|input\n|text|/ghost")

end

--#endregion

--#region place plats

local make_farm = {
    enabled = false,
}

function do_make_farm()

    if not is_in_world() then
        send_console_msg("Enter a world")
        return
    end

    local_world.name = GetLocal().world

    if not check_remote() then
        send_console_msg("Wrench Magplant and Get Remote.")
       return
    end
    
    send_console_msg("Started Making Farm")

    for y = local_world.size_y, 0, -1 do

        if y % 2 == 1 then
            y = y - 1
        end

        for x = 0, local_world.size_x, 1 do

            if not make_farm.enabled then
                return
            end
    
            if local_world.name ~= GetLocal().world then
                send_console_msg("Stopped Making Farm: exit world: " .. GetLocal().world .. ", " .. local_world.name)
                return
            end
    
            if GetTile(x, y).fg == 0 and not (x == 0 or x == local_world.size_x) then
                FindPath(x, y - 1)
                Sleep(params.delay + 60)
                pkt_punch(x, y, 5640)
                Sleep(params.delay + 130)
            end

        end
    end

    make_farm.enabled = false

    if make_farm.enabled == false then
        send_console_msg("Finished Making Farm.")
    end

end


--#endregion

--#region refill mag

local refill_mag = {
    enabled = false
}

function do_refill_mag()

    if not is_in_world() then
        send_console_msg("Enter a world")
        return
    end

    if mag.x == nil or mag.y == nil then
        send_console_msg("Wrench Magplant and Update it")
        refill_mag.enabled = false
        return
    end

    local_world.name = GetLocal().world

    send_console_msg("Started Refill Mag")

    local lp = GetLocal()

    if local_world.name ~= GetLocal().world then
        send_console_msg("Stopped Making Farm: exit world: " .. GetLocal().world .. ", " .. local_world.name)
        return
    end

    for _,object in pairs(GetObjects()) do
        
        if math.floor(object.pos_x/32) ~= math.floor(lp.tile_x) or math.floor(object.pos_y/32) ~= math.floor(lp.tile_y) then
            goto continue
        end

        while true do
            SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. mag.x .. "|\ny|" .. mag.y .. "|\nbuttonClicked|additems")
            Sleep(50)
            if math.floor(object.pos_x/32) ~= math.floor(lp.tile_x) or math.floor(object.pos_y/32) ~= math.floor(lp.tile_y) then
               break;
            end
        end

        ::continue::
    end

    refill_mag.enabled = false

    if refill_mag.enabled == false then
        send_console_msg("Finished Refilling Mag.")
    end

end

--#endregion

--#region callbacks

local handle_callbacks = {}

-- {str name, str callback, void* func}
handle_callbacks.callbacks = {}

handle_callbacks.remove_callbacks = function()
    for i = 1, #handle_callbacks.callbacks do
        RemoveCallback(handle_callbacks.callbacks[i][1])
    end
end

handle_callbacks.add_callbacks = function()
    for i = 1, #handle_callbacks.callbacks do
        AddCallback(table.unpack(handle_callbacks.callbacks[i]))
    end
end

local ignore_error = false

function hook_packet(type, packet)

    if packet:find("action|input\n|text|/farm quit") then
        send_console_msg("Quitting.")
        handle_callbacks.remove_callbacks()
        harvest.enabled = false
        plant.enabled = false
        make_farm.enabled = false
        refill_mag.enabled = false
    end
    
    if packet:find("action|input\n|text|/farm harvest") then
        local_world.name = GetLocal().world
        harvest.enabled = not harvest.enabled
    end

    if packet:find("action|input\n|text|/farm plant") then
        local_world.name = GetLocal().world
        plant.enabled = not plant.enabled
    end

    if packet:find("action|input\n|text|/farm make_farm") then
        local_world.name = GetLocal().world
        make_farm.enabled = not make_farm.enabled
    end

    if packet:find("action|input\n|text|/farm refill_mag") then
        local_world.name = GetLocal().world
        refill_mag.enabled = not refill_mag.enabled
    end

    if packet:find("dialog_name|magplant_edit") then
        local_world.name = GetLocal().world
        mag.x = packet:match('x|(%d+)')
        mag.y = packet:match('y|(%d+)')
        send_console_msg(string.format("Logged mag at (%d, %d)", mag.x, mag.y))
    end

    if packet:find("action|input\n|text|/farm") then
        ignore_error = true
    end

    if packet:find("action|input\n|text|/farm help") then
        SendVarlist({
            [0] = "OnDialogRequest",
            [1] = [[set_default_color|`o
add_label_with_icon|big|`3Farm Helper Command List``|left|5638|
add_spacer|small|
add_textbox|`9Command : `0/farm help `0( `3show commands `0)|left|
add_textbox|`9Command : `0/farm harvest `0( `3toggle harvest`0)|left|
add_textbox|`9Command : `0/farm plant `0( `3toggle plant `8[magplant]`0)|left|
add_textbox|`9Command : `0/farm make_farm `0( `3toggle make farm `8[magplant]`0)|left|
add_textbox|`9Command : `0/farm refill_mag `0( `3toggle refill mag `8[magplant]`0)|left|
add_spacer|small|
add_textbox|`9Made by: `3bocho#8180``|left|
add_quick_exit|
end_dialog|farm_help|Okay|
            ]],
            netid = -1
        })
    end

end

table.insert(handle_callbacks.callbacks, {"hook_packet", "OnPacket", hook_packet})

function hook_varlist(varlist, packet)
    
    if varlist[0] == "OnTalkBubble" and varlist[2] == "The MAGPLANT 5000 is empty." then
        plant.enabled = false
        return true
    end

    if varlist[0] == "OnConsoleMessage" and varlist[1] == "`4Unknown command. `oEnter /`$? ``for a list of valid commands.``" and ignore_error then
        ignore_error = false
        return true
    end

    if varlist[0] == "OnTalkBubble" and varlist[1] == GetLocal().netid and varlist[2] == "You don't have this item to do that!" and refill_mag then
        refill_mag.enabled = false
        return true
    end

end

table.insert(handle_callbacks.callbacks, {"hook_varlist", "OnVarlist", hook_varlist})

handle_callbacks.add_callbacks()

--#endregion


while true do

    Sleep(1000)

    set_world_size()

    if harvest.enabled then
        do_harvest()
    end

    if plant.enabled then
        do_plant()
    end

    if make_farm.enabled then
        do_make_farm()
    end

    if refill_mag.enabled then
        do_refill_mag()
    end

end
