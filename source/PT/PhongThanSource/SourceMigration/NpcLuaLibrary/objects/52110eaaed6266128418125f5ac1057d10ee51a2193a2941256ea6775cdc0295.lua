--hongliang ºìÉ°Õó 10/10/29


--------------------------------------
--¸±±¾ÁÙÊ±±äÁ¿
--1 ~ 4: TABLE_NpcÖÐNpcµÄIdx
--5 ~ 8: TABLE_NpcÖÐNpcµÄID

TASK_Instance_HSZ = 601 --1st byte: Òýµ¼ÈÎÎñ²½Öè 0-Î´½Ó;1-ÒÑ½Ó;2-ÒÑºÍµÀÈË¶Ô»°;3-ÒÑ´ðÓ¦ÎäÍõ;4-ÒÑÉ±ËÀboss;5-ÒÑÍê³ÉÈÎÎñ;

NPCTVID_InstanceIdx = 0;
NPCTVID_InstanceId = 1;

INSTANCE_TYPE_HSZ = 10

BUFF_InstanceTime = 1344
Timer_Check = 68
Timer_End = 69
--------------------------------------



-- ¸±±¾Session¶¨Ê±Æ÷µ½Ê±´¥·¢º¯Êý£¬×Ô¶¯µ÷ÓÃ
function OnTimer()
    local cachePlayerIndex = PlayerIndex
    local nIdx, nextPlayerIdx = 0, 0
    while 1 do
        nIdx, nextPlayerIdx = GetSessionNextPlayer(nIdx, 0)
        if (nIdx == 0) then
            break
        end
        PlayerIndex = nextPlayerIdx
        if (GetTeam() == 0) then
            Msg2Player("Kh«ng cã sù trî gióp cña ®ång ®éi thËt nguy hiÓm, b¹n bÞ c­ìng chÕ rêi khái Hång Sa TrËn.")
            NewWorld(20, 1448, 3086)
            SetFightState(0)
        end
    end
    PlayerIndex = cachePlayerIndex
end

