local island_blast_items = {-154, -156, 14, 1102, 1104, 15, 1105, 1103, -153, -155, 5028, 5036} -- every item in an island blast
local nether_blast_items = {4, 5, 380, 381, 682, 683} -- every item in n nether blast

local item_ids = {}

for _, value in ipairs(island_blast_items) do
    table.insert(item_ids, value)
end

for _, value in ipairs(nether_blast_items) do
    table.insert(item_ids, value)
end

function count(id)
    local count = 0
    for _, inv in pairs(GetInventory()) do
        if id < 0 then
            id = 13940 + id
        end
       if inv.id == id then
          count = count + inv.count
       end
    end
    return count
end

function main()
    
    while true do
        
        for i = 1, #item_ids do

            local item_count = count(item_ids[i])

            --log(item_ids[i] .. ", " .. item_count)
            
            if item_count > 100 then
                SendPacket(2, "action|dialog_return\ndialog_name|trash\nitem_trash|" .. item_ids[i] .. "|\nitem_count|" .. item_count)
            end

            Sleep(20)

        end

        Sleep(50)

    end

end

main()