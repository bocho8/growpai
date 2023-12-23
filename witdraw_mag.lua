--[[
    made by bocho#8180
    usage: retrieve items and drop them, then it will drop everything on the mag for you ;)
]]

local params = {
    delay = 200,
}

local mag = {
    x,
    y,
}

local item_id

local world

function hook_packet(type, packet)
    
    if packet:find("dialog_name|magplant_edit") and packet:find("buttonClicked|withdraw") then
        mag.x = packet:match("x|(%d+)")
        mag.y = packet:match("y|(%d+)")
        world = GetLocal().world
    end

    if packet:find("dialog_name|drop") then
        item_id = packet:match("item_drop|[%d%-]+"):match("%|.*"):sub(2)
    end

end

AddCallback("hook_packet", "OnPacket", hook_packet)

while true do

    --log(string.format("item id: %s\nmag.x: %s, mag.y: %s\nworld: %s", tostring(item_id), tostring(mag.x), tostring(mag.y), tostring(world)))

    if world == nil or item_id == nil then
        goto skip
    end
    
    if GetLocal().world ~= world then
        RemoveCallbacks()
        break;
    end

    SendPacket(2, string.format("action|dialog_return\ndialog_name|magplant_edit\nx|%d|\ny|%d|\nbuttonClicked|withdraw", mag.x, mag.y))

    Sleep(params.delay + 50)

    SendPacket(2, string.format("action|dialog_return\ndialog_name|drop\nitem_drop|%d|\nitem_count|250", item_id))

    ::skip::

    Sleep(params.delay + 50)

end