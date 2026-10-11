int GetPlayerIndex(Lua_State * L)
{
    Lua_GetGlobal(L, SCRIPT_PLAYERINDEX);
    if (lua_isnil(L,Lua_GetTopIndex(L)))
        return -1;
    int nIndex = (int)Lua_ValueToNumber(L, Lua_GetTopIndex(L));
    if (nIndex >= MAX_PLAYER || nIndex <= 0)
    {
        _ASSERT(0);
        return -1;
    }	if (Player[nIndex].m_nIndex >= MAX_NPC || Player[nIndex].m_nIndex < 0)
    {
        _ASSERT(0);
        return -1;
    }
    return nIndex;
}
static BOOL MapVngNormalItemTuple(int nGenre, int nDetail, int nParticular,
	int* pnRuntimeGenre, int* pnRuntimeDetail)
{
	if (!pnRuntimeGenre || !pnRuntimeDetail)
		return FALSE;
	*pnRuntimeGenre = -1;
	*pnRuntimeDetail = -1;

	if (nGenre == item_materials && nDetail >= 0 && nParticular == 0)
	{
		*pnRuntimeGenre = item_materials;
		*pnRuntimeDetail = nDetail;
		return TRUE;
	}
	if (nGenre == item_task && nDetail >= 0)
	{
		*pnRuntimeGenre = item_task;
		*pnRuntimeDetail = nDetail;
		return TRUE;
	}
	if (nGenre == item_magicscript && nDetail == 1 && nParticular > 0)
	{
		*pnRuntimeGenre = item_magicscript;
		*pnRuntimeDetail = nParticular;
		return TRUE;
	}
	if (nGenre == 8 && nDetail >= 0 && nParticular >= 0)
	{
		*pnRuntimeGenre = item_ibitem;
		*pnRuntimeDetail = nDetail;
		return TRUE;
	}
	return FALSE;
}
static BOOL GetVngNormalTuple(Lua_State *L, int nStart,
    int *pnGenre, int *pnDetail, int *pnLevel, int *pnSeries)
{
    if (Lua_GetTopIndex(L) < nStart + 3)
        return FALSE;
    int nRuntimeGenre = -1;
    int nRuntimeDetail = -1;
    if (!MapVngNormalItemTuple(
        (int)Lua_ValueToNumber(L, nStart),
        (int)Lua_ValueToNumber(L, nStart + 1),
        (int)Lua_ValueToNumber(L, nStart + 2),
        &nRuntimeGenre, &nRuntimeDetail))
        return FALSE;
    *pnGenre = nRuntimeGenre;
    *pnDetail = nRuntimeDetail;
    *pnLevel = (int)Lua_ValueToNumber(L, nStart + 3);
    *pnSeries = Lua_GetTopIndex(L) >= nStart + 4 ? (int)Lua_ValueToNumber(L, nStart + 4) : -1;
    return TRUE;
}
int LuaHaveNormalItemCompat(Lua_State *L)
{
    // GetPlayerIndex pushes its global onto the Lua stack. Do not interpret
    // that value as the optional fifth (series) argument of a four-field tuple.
    const int nArgumentCount = Lua_GetTopIndex(L);
    int nPlayerIndex = GetPlayerIndex(L);
    Lua_SetTopIndex(L, nArgumentCount);
    int nGenre = -1, nDetail = -1, nLevel = -1, nSeries = -1;
    int nCount = 0;
    if (nPlayerIndex > 0 && GetVngNormalTuple(L, 1, &nGenre, &nDetail, &nLevel, &nSeries))
        nCount = CountVngOwnedItems(nPlayerIndex, nGenre, nDetail, nLevel, nSeries, -1);
    Lua_PushNumber(L, nCount);
    return 1;
}
int LuaDelNormalItemCompat(Lua_State *L)
{
    // Match HaveNormalItem: only caller-supplied tuple fields may filter items.
    const int nArgumentCount = Lua_GetTopIndex(L);
    int nPlayerIndex = GetPlayerIndex(L);
    Lua_SetTopIndex(L, nArgumentCount);
    int nGenre = -1, nDetail = -1, nLevel = -1, nSeries = -1;
    int nRemoved = 0;
    if (nPlayerIndex > 0 && GetVngNormalTuple(L, 1, &nGenre, &nDetail, &nLevel, &nSeries))
        nRemoved = RemoveVngItems(nPlayerIndex, nGenre, nDetail, nLevel, nSeries, pos_equiproom, FALSE);
    Lua_PushNumber(L, nRemoved);
    return 1;
}