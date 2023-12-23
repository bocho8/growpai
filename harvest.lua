local local_world = {
    size_x = 200,
    size_y = 200,
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
      int_y = y,
    }
   SendPacketRaw(packet)
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
    
            if GetTile(x, y).ready and GetIteminfo(GetTile(x, y).fg).growth > 0 then
                FindPath(x - x_increment, y)
                Sleep(60)
                pkt_punch(x, y, 18)
                Sleep(130)
            end

        end
    end