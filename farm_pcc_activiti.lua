-- convert activity points to pcc while farming them

local PCC_ITEM_ID = 13964

while true do
    if GetItemCount(PCC_ITEM_ID) < 1 then
        SendPacket(2, "action|dialog_return\ndialog_name|activity_purchase\noffer|2|")
    end
    Sleep(200)
end