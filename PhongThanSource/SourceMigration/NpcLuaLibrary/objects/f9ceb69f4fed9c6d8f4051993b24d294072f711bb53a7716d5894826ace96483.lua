--Add By Guoqun for ∏ﬂº∂ ¶√≈÷ÆΩŸƒ—»ŒŒÒ at 2009.12.28 Begin
YIBO_TIME = 1659 -- 1Word:¥¥Ω®“¬≤ßπÿœµ ±µƒ ±º‰£®ÃÏ ˝£©
-- 2Word:≈—¿Î ¶√≈µƒ ±º‰£®ÃÏ ˝£©
YIBO_80_DESASTER_STATE = 1661  -- 1Byte:»ŒŒÒ«Èøˆ 1°¢“—æ≠Ω”»ŒŒÒ  2°¢ÕÍ≥…  3°¢ ß∞‹
-- 2Byte:¡‘…±∂‘œÛ 1«Ó∆Ê 2óÉËª 3˜“˜— 4ªÏ„Á
-- 3Byte:Ω«…´ 1 ¶∏∏ 2ÕΩµ‹£®◊ˆ¥À±Íº«µƒ‘≠“Ú «£¨‘⁄ÕÍ≥…»ŒŒÒ“‘∫Û£¨»Áπ˚Ω”¥• ¶ÕΩπÿœµ£¨ø…“‘“¿»ª¡Ï»°Ω±¿¯£©
-- 4Byte:“— ’µΩ” º˛Ã·–—
SEVEN_DAY_BUFF = 1239
--Add By Guoqun for ∏ﬂº∂ ¶√≈÷ÆΩŸƒ—»ŒŒÒ at 2009.12.28 End

function OnDeath(npcidx)
    if (GetGlobalValue(155) > 0) then
        DelNpc(GetGlobalValue(155))
        SetGlobalValue(155, 0)
    end
    --Add By Guoqun for ∏ﬂº∂ ¶√≈÷ÆΩŸƒ—»ŒŒÒ at 2009.12.28 Begin
    Check_ShituExist(npcidx)
    --Add By Guoqun for ∏ﬂº∂ ¶√≈÷ÆΩŸƒ—»ŒŒÒ at 2009.12.28 End

    SetGlobalValue(105, -1)
    DelNpc(npcidx)
    AddNormalItem(3, 123, 0, 0, 0, 1)
    Msg2Player("Bπn nhÀn Æ≠Óc ßµo C¨!")
    local i = GetName()
    local j = GetLevel()
    if (j <= 90) then
        AddGlobalCountNews("DÚng s‹ <c=g>" .. i .. "<c> mÈt ki’m hπ s∏t <c=g>Lam B∏<c>, nh©n gian lπi Æ≠Óc h≠Îng s˘ thanh b◊nh.", 20)
    end ;
    local w, x, y = GetWorldPos()
    local lvl = GetNpcLevel(npcidx)
    if (GetTeam() ~= 0) then

        local oldPlayer = PlayerIndex
        local membercount = GetTeamSize()

        for i = 1, membercount do
            PlayerIndex = GetTeamMember(i)
            city_shouji(w)
        end
        PlayerIndex = oldPlayer
    else
        city_shouji(w)
    end ;
end;

--Add By Guoqun for ∏ﬂº∂ ¶√≈÷ÆΩŸƒ—»ŒŒÒ at 2009.12.28 Begin
function Check_ShituExist(npcidx)
    -- ±È¿˙À˘‘⁄∂”ŒÈµƒÕÊº“£¨≈–∂œƒ≥ÕÊº“ «∑Ò‘⁄∂”ŒÈ÷–
    local nSize = GetTeamSize()
    if (nSize > 0) then
        for i = 1, nSize do
            PlayerIndex = GetTeamMember(i)
            if (GetTaskByte(YIBO_80_DESASTER_STATE, 2) == 4) then
                if (IsMantlePrentice(PlayerIndex) > 0 and IsPlayerInDeath() == 0) then
                    --»Áπ˚ÕÊº“ «“¬≤ßµ‹◊”£¨‘Ú≤È’“ ¶∏∏ «∑Ò‘⁄∂”ŒÈ÷–
                    local masterIdx = Check_MasterIdx()
                    if (masterIdx > 0) then
                        local bDis = Check_Distance(PlayerIndex, masterIdx, npcidx)
                        if (bDis > 0) then
                            -- ¶ÕΩ∂º‘⁄∂”ŒÈ÷–£¨≤¢«“æ‡¿Î≤ª≥¨π˝2∆¡
                            if (HaveIBBuff(SEVEN_DAY_BUFF) == 0 and GetTaskByte(YIBO_80_DESASTER_STATE, 1) == 1) then
                                Msg2Player("Bπn kh´ng hoµn thµnh ßÈ Ki’p trong thÍi gian hπn Æﬁnh!")
                                SetTaskByte(YIBO_80_DESASTER_STATE, 1, 3)
                            else
                                SetTaskByte(YIBO_80_DESASTER_STATE, 1, 2)
                                SetTaskWord(YIBO_TIME, 1, 0)
                                Msg2Player("ChÛc mıng bπn Æ∑ v≠Ót qua Æ≠Óc ki’p nπn, h∑y v“ phÙc m÷nh Th«y t≠Ìng sË!")
                                TaskNote(1516, 1)
                                RemoveIBBuff(SEVEN_DAY_BUFF)
                                PlayerIndex = masterIdx

                                SetTaskByte(YIBO_80_DESASTER_STATE, 1, 2)
                                SetTaskWord(YIBO_TIME, 1, 0)
                                Msg2Player("ChÛc mıng bπn Æ∑ hÁ trÓ ÆÂ Æ÷ v≠Ót qua Æ≠Óc ki’p nπn, h∑y v“ phÙc m÷nh Th«y t≠Ìng sË!")
                            end
                        else
                            PlayerIndex = masterIdx
                            Msg2Player("Bπn vµ Y B∏t Æ÷ tˆ cÒa bπn c∏ch nhau qu∏ xa, kh´ng th” giÛp Æ÷ tˆ ßÈ Ki’p!")
                            PlayerIndex = GetTeamMember(i)
                            Msg2Player("Bπn vµ Y B∏t S≠ PhÙ cÒa m◊nh c∏ch nhau qu∏ xa, kh´ng th” hoµn thµnh ßÈ Ki’p!")
                        end
                    end
                end
            end
        end
    end
    return 0
end

function Check_MasterIdx()
    --±È¿˙∂”ŒÈ£¨—∞’“ ¶∏∏ «∑Ò‘⁄∂”ŒÈ÷–(’‚¿Ô–Ë“™Ω”ø⁄) ’‚¿Ô≤Èø¥  ¶∏∏ «∑Ò‘⁄∂”ŒÈ÷–
    local nSize = GetTeamSize()
    local strMasterName = GetMantleMasterName()
    local selfIdx = PlayerIndex
    for i = 1, nSize do
        PlayerIndex = GetTeamMember(i)
        if (strMasterName == GetName()) then
            PlayerIndex = selfIdx
            return GetTeamMember(i)
        end
    end
    return 0
end

function Check_Distance(playerIdx1, playerIdx2, npcidx)
    --∑µªÿ÷µÀµ√˜£∫1 æ‡¿Î’˝»∑ 0æ‡¿Î¥ÌŒÛ
    local nMapid, nX, nY = GetNpcWorldPos(npcidx)
    local selfIdx = PlayerIndex
    PlayerIndex = playerIdx1
    local pMapid1, pX1, pY1 = GetWorldPos()
    PlayerIndex = playerIdx2
    local pMapid2, pX2, pY2 = GetWorldPos()
    PlayerIndex = selfIdx
    if (pMapid1 == nMapid and pMapid2 == nMapid) then
        if (((nX - pX1) ^ 2 + (nY - pY1) ^ 2) < 500) and (((nX - pX2) ^ 2 + (nY - pY2) ^ 2) < 1000) then
            return 1
        end
    end
    return 0
end
--Add By Guoqun for ∏ﬂº∂ ¶√≈÷ÆΩŸƒ—»ŒŒÒ at 2009.12.28 End

TASK_today = 886
task_id = 864
item_id = 166
type_id = 11
item_name = "ß«u Lam B∏"

function city_shouji(world)
    local w, x, y = GetWorldPos()
    if (w == world) then
        local task_val = GetTask(task_id)
        local type1 = GetByte(task_val, 1)
        local count1 = GetByte(task_val, 2)
        local type2 = GetByte(task_val, 3)
        local count2 = GetByte(task_val, 4)

        local item_count = IsExistItem(4, item_id, 0, 1)
        if (type1 == type_id) then
            local today = floor(LocalSystemTime() / 86400)
            if (today == GetTask(TASK_today)) then
                if (type2 == 0) and (count2 == 3) then
                    AddNormalItem(4, item_id, 0, 0, 0, 0)
                    item_count = item_count + 1

                    if (item_count < count1) then
                        Msg2Player("Cﬂn ph∂i thu thÀp" .. item_name .. (count1 - item_count) .. ".")
                    else
                        Msg2Player("Thu thÀp ÆÒ" .. item_name .. ".")
                    end
                    SetTask(task_id, SetByte(task_val, 4, 0))
                else
                    Msg2Player("H´m nay Æ∑ giao cho ng≠¨i" .. item_name .. ", ng≠¨i ph∂i ti’p tÙc giao nÈp rÂi nhÀn lπi mÌi c„ th” nhÀn Æ≠Óc")
                end
            else
                Msg2Player("Nhi÷m vÙ L›nh Æ∏nh thu™ Æ∑ h’t hπn")
            end
        end
    end
end
