local seed_id = 5640 -- 5640 = magplant id

local local_world = {
    size_x = 199,
    size_y = 199
}

function set_world_size()
    local x, y = {}, {}

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

function pkt_punch(x, y, id)
    local lp = GetLocal()
    local packet = {
        type = 3,
        int_data = id,
        pos_x = lp.pos_x,
        pos_y = lp.pos_y,
        int_x = x,
        int_y = y
    }
    SendPacketRaw(packet)
end

local x_increment, x_max, x_start, x_offset

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
        if GetTile(x, y).fg == 0 and (GetIteminfo(GetTile(x, y + 1).fg).name:find("Platform") or GetIteminfo(GetTile(x, y + 1).fg).name:find("Waterslide Strut")) then
            FindPath(x, y)
            Sleep(20)

            x_offset = -4
            while x_offset < 5 do
                if GetTile(x + x_offset, y).fg == 0 and (GetIteminfo(GetTile(x + x_offset, y + 1).fg).name:find("Platform") or GetIteminfo(GetTile(x + x_offset, y + 1).fg).name:find("Waterslide Strut")) then
                    pkt_punch(x + x_offset, y, seed_id)
                    Sleep(90)
                end
                x_offset = x_offset + 1
            end
        end
    end
end

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

        if
            GetTile(x, y).fg == 0 and GetTile(x, y + 1).fg ~= 0 and not (x == 0 or x == local_world.size_x) --[[and GetIteminfo(GetTile(x, y + 1).fg).name:find("Platform") or GetIteminfo(GetTile(x, y + 1).fg).name:find("Waterslide Strut")]]
         then
            FindPath(x, y)
            Sleep(40)
            pkt_punch(x, y, 5640)
            Sleep(120)
        end
    end
end
