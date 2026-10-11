require("common.luax")
Unpack_TABLE = COMMON.Unpack_TABLE

function no()
    CloseDialog()
end

-- Phong Than local fix 2026-09-28: the server calls item main() with the item
-- index as the FIRST argument; DelItemByID/IsItemBind are not registered.
function main(nLevel, nTime, nTNpcIdx, itemID)
    itemID = itemID or nLevel
    CloseDialog()
    local nParticular = GetItemPartByID(itemID)
    if (nParticular < 1571) then
        return
    elseif (nParticular > 1593) then
        return
    end

    local idx = nParticular - 1570
    if (idx <= 0 or idx > getn(Unpack_TABLE)) then
        return
    end
    SetTask(140, itemID)
    SetTask(141, idx)

    local str = Unpack_TABLE[idx].nums .. "." .. Unpack_TABLE[idx].name
    MsgBox("Ban muon <c=g>mo goi nay<c>? Se nhan duoc <c=y>" .. str .. "<c>!\nHay chu y cho trong trong hanh trang.", "Unpackyes", "no")
end

function Unpackyes()
    CloseDialog()
    if (IsHaveSpaceForTreasure(2) == 0) then
        Talk(1, "no", "Hanh trang khong du cho trong, hay don hanh trang roi mo lai.")
        return
    end

    local itemID = GetTask(140)
    local nParticular = GetItemPartByID(itemID)
    if (nParticular < 1571) then
        Talk(1, "no", "Mo goi that bai, vui long thu lai!")
        return
    elseif (nParticular > 1593) then
        Talk(1, "no", "Mo goi that bai, vui long thu lai!")
        return
    end

    local idx = nParticular - 1570
    if (GetTask(141) ~= idx) then
        Talk(1, "no", "Mo goi that bai, vui long thu lai!")
        return
    end
    SetTask(140, 0)
    SetTask(141, 0)
    local isBind = 0
    if IsItemBind and (IsItemBind(itemID) > 0) then
        isBind = 1
    end

    local nDel = 0
    if DelItemByID then nDel = DelItemByID(itemID) else nDel = RemoveItem(itemID, 1, 0) end
    if ((nDel or 0) < 1) then
        Talk(1, "no", "Mo goi that bai, vui long thu lai!")
        return
    end

    local nNums = Unpack_TABLE[idx].nums
    local id = Unpack_TABLE[idx].malterItem
    for i = 1, nNums do
        if (isBind == 1) then
            AddNormalItemBind(id[1], id[2], id[3], id[4], 0, 0, 1)
        else
            AddNormalItemPile(id[1], id[2], id[3], id[4], 0, 0)
        end
    end

    Msg2Player("Mo goi nhËn ®­îc " .. nNums .. "." .. Unpack_TABLE[idx].name)
    -- ScrollMessage broadcast removed: original text was untranslated GBK.
    WriteLog("[½â°ü]" .. Unpack_TABLE[idx].name .. "[°ó¶¨]" .. isBind)
end
