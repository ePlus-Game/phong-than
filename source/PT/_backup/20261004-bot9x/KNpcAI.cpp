#include "KCore.h"
#include "KNpc.h"
#include "KNpcSet.h"
#include "KSubWorld.h"
#include "KMath.h"
#include "KObj.h"
#include "KPlayer.h"
#include "KNpcAI.h"
#include "KSellItem.h"

// flying add here, to use math lib
#include <math.h>
extern int GetRandomNumber(int nMin, int nMax);

#define		MAX_FOLLOW_DISTANCE		48
#define		FOLLOW_WALK_DISTANCE	100

KNpcAI NpcAI;

KNpcAI::KNpcAI()
{
	m_nIndex = 0;
	m_bActivate = TRUE;
}

// flying modified this function.
// Jun.4.2003

void KNpcAI::NotActivate(int nIndex)
{
	m_nIndex = nIndex;	
	if (Npc[m_nIndex].IsPlayer())
	{
	#ifdef _SERVER
	TriggerObjectTrap();
	TriggerMapTrap();
	#endif
	}

}



#ifdef _SERVER
// Phong Than 2026-10-03 vantieu: AiMode 12 = escort carriage (SendCarriage, PhongThanLuaCarriage.h).
// Walks after its owner player (Owner name + m_nOwnerIdx) and never attacks. It stands still while the
// owner is away (other map, dead, offline, more than 1600 points away); the Lua timer of the carriage
// (\script\phongthan\vanluong\vl_lib.lua) decides failure and timeout.
static void PhongThanCarriageFollow(int nIndex)
{
	KNpc &rCart = Npc[nIndex];
	int nOwner = rCart.m_nOwnerIdx;
	if (nOwner <= 0 || nOwner >= MAX_NPC || Npc[nOwner].m_dwID == 0 ||
		Npc[nOwner].m_Kind != kind_player || Npc[nOwner].m_RegionIndex < 0 ||
		Npc[nOwner].m_SubWorldIndex != rCart.m_SubWorldIndex ||
		!rCart.Owner[0] || strcmp(Npc[nOwner].Name, rCart.Owner) != 0 ||
		!Npc[nOwner].IsAlive())
		return;
	int nX = 0, nY = 0, nOwnX = 0, nOwnY = 0;
	rCart.GetMpsPos(&nX, &nY);
	Npc[nOwner].GetMpsPos(&nOwnX, &nOwnY);
	int nDist = g_GetDistance(nX, nY, nOwnX, nOwnY);
	if (nDist > 1600)
		return;
	if (nDist > 480)
		rCart.SendCommand(do_run, nOwnX, nOwnY);
	else if (nDist > 96)
		rCart.SendCommand(do_walk, nOwnX, nOwnY);
}
#endif

#ifdef _SERVER
// Phong Than 2026-10-03 cppbatch:H3 AiMode 13 = companion pet (Linh thu; SetNpcAiMode, PhongThanLuaCppBatch.h).
// Same owner rules as AiMode 11 (ProcessAIType11): the pet is removed when its owner leaves the map, dies,
// hides or logs out (the Lua minute tick of script\phongthan\ext\sinhhoat.lua summons it again). Otherwise it
// walks or runs after its owner like the escort carriage (AiMode 12) and never attacks anything.
static void PhongThanCompanionRemove(int nIndex)
{
	KNpc &rPet = Npc[nIndex];
	if (rPet.m_SubWorldIndex >= 0 && rPet.m_SubWorldIndex < MAX_SUBWORLD && rPet.m_RegionIndex >= 0)
	{
		SubWorld[rPet.m_SubWorldIndex].m_Region[rPet.m_RegionIndex].RemoveNpc(nIndex);
		SubWorld[rPet.m_SubWorldIndex].m_Region[rPet.m_RegionIndex].DecRef(rPet.m_MapX, rPet.m_MapY, obj_npc);
	}
	NpcSet.Remove(nIndex);
}

static void PhongThanCompanionFollow(int nIndex)
{
	KNpc &rPet = Npc[nIndex];
	int nOwner = rPet.m_nOwnerIdx;
	if (nOwner <= 0 || nOwner >= MAX_NPC || Npc[nOwner].m_dwID == 0 ||
		Npc[nOwner].m_Kind != kind_player || Npc[nOwner].m_RegionIndex < 0 ||
		Npc[nOwner].m_SubWorldIndex != rPet.m_SubWorldIndex ||
		(rPet.Owner[0] && strcmp(Npc[nOwner].Name, rPet.Owner) != 0) ||
		Npc[nOwner].m_CurrentLifeMax <= 0 || Npc[nOwner].m_HideState.nTime > 0 ||
		!Npc[nOwner].IsAlive())
	{
		PhongThanCompanionRemove(nIndex);
		return;
	}
	rPet.m_nPeopleIdx = 0;
	int nX = 0, nY = 0, nOwnX = 0, nOwnY = 0;
	rPet.GetMpsPos(&nX, &nY);
	Npc[nOwner].GetMpsPos(&nOwnX, &nOwnY);
	int nDist = g_GetDistance(nX, nY, nOwnX, nOwnY);
	if (nDist > 360)
		rPet.SendCommand(do_run, nOwnX, nOwnY);
	else if (nDist > 120)
		rPet.SendCommand(do_walk, nOwnX, nOwnY);
}
#endif

void KNpcAI::Activate(int nIndex)
{
	m_nIndex = nIndex;	
	if (Npc[m_nIndex].IsPlayer())
	{
		// ������Player AI���������ʵ�֡�
		ProcessPlayer();
		return;
	}
#ifdef _SERVER
	if (Npc[m_nIndex].m_CurrentLifeMax == 0)
		return;
	if (Npc[m_nIndex].Owner[0] && Npc[m_nIndex].m_bNpcFollowFindPath)
	{
		FindPathNpc();
		return;
	
	}
	int nCurTime = SubWorld[Npc[m_nIndex].m_SubWorldIndex].m_dwCurrentTime;
	if (/*Npc[m_nIndex].m_nPeopleIdx ||*/Npc[m_nIndex].m_NextAITime <= nCurTime)
	{
		Npc[m_nIndex].m_NextAITime = nCurTime + Npc[m_nIndex].m_AIMAXTime;
		switch(Npc[m_nIndex].m_AiMode)
		{
		case 1:
			ProcessAIType01();
			break;
		case 2:
			ProcessAIType02();
			break;
		case 3:
			ProcessAIType03();
			break;
		case 4:
			ProcessAIType04();
			break;
		case 5:
			ProcessAIType05();
			break;
		case 6:
			ProcessAIType06();
			break;
		case 11:
			ProcessAIType11();
			break;
		case 12:	// Phong Than 2026-10-03 vantieu: escort carriage
			PhongThanCarriageFollow(m_nIndex);
			break;
		case 13:	// Phong Than 2026-10-03 cppbatch:H4 companion pet, follows and never attacks
			PhongThanCompanionFollow(m_nIndex);
			break;
/*		case 7:
			ProcessAIType7();
			break;
		case 8:
			ProcessAIType8();
			break;
		case 9:
			ProcessAIType9();
			break;
		case 10:
			ProcessAIType10();
			break;*/
		default:
			break;
		}
	}
// flying add the code for the macro such as "_CLIENT".
// because this code only run at client.
#else
/*	if (Npc[m_nIndex].m_Kind >= kind_bird && Npc[m_nIndex].m_AiMode > 10)
	{
		if (CanShowNpc())
		{
			// ��NPC�����Ϣһ�£��Ǹ��ý��顣
			if (GetRandomNumber(0, 1))	
			{
				Npc[m_nIndex].m_AiParam[5] = 0;
				Npc[m_nIndex].m_AiParam[4] = 5;
				return;
			}
			if (!KeepActiveRange())
				ProcessShowNpc();
		}
	}*/
#endif
}


#define	MAX_FIND_PATH_NPC_DISTANCE 750
#define	MIN_FIND_PATH_NPC_DISTANCE 32
#define	MAX_WAIT_PATH_NPC_TIME 5*60*20 //5 minute
#define	MAX_FIND_PATH_NPC_TIME 30*60*20 //30 minute

#ifdef _SERVER
void	KNpcAI::FindPathNpc()
{
	int nIdx = Npc[m_nIndex].FindAroundPlayer(Npc[m_nIndex].Owner);

	if (nIdx <= 0 || Npc[nIdx].m_dwID <= 0)
		return;

	if (Npc[m_nIndex].m_SubWorldIndex != Npc[nIdx].m_SubWorldIndex)
		return;

	if (Npc[nIdx].m_Doing == do_death || Npc[nIdx].m_Doing == do_revive)
		return;

	if (Npc[m_nIndex].m_uFindPathTime)
	{
		if (Npc[m_nIndex].m_uFindPathMaxTime != -1)
		{
			DWORD dwTime = MAX_FIND_PATH_NPC_TIME;

			if (Npc[m_nIndex].m_uFindPathMaxTime > 0)
				dwTime = Npc[m_nIndex].m_uFindPathMaxTime;

			if (g_SubWorldSet.GetGameTime() - Npc[m_nIndex].m_uFindPathTime > dwTime)
			{
				if (Npc[m_nIndex].m_RegionIndex >= 0)
				{
					SubWorld[Npc[m_nIndex].m_SubWorldIndex].m_Region[Npc[m_nIndex].m_RegionIndex].RemoveNpc(m_nIndex);
					SubWorld[Npc[m_nIndex].m_SubWorldIndex].m_Region[Npc[m_nIndex].m_RegionIndex].DecRef(Npc[m_nIndex].m_MapX, Npc[m_nIndex].m_MapY, obj_npc);
				}
				NpcSet.Remove(m_nIndex);
				return;
			}
		}
	}
	// ȡ�õ�Ŀ��ľ���
	int distance = NpcSet.GetDistance(nIdx, m_nIndex);
	if (distance <= MAX_FIND_PATH_NPC_DISTANCE)
	{
		if (Npc[m_nIndex].m_CurrentCamp != camp_event)
			Npc[m_nIndex].SetCurrentCamp(camp_event);

		if (distance > MIN_FIND_PATH_NPC_DISTANCE)
		{
			if (Npc[m_nIndex].m_uLastFindPathTime)
				Npc[m_nIndex].m_uLastFindPathTime = 0;

			int nDesX, nDesY;
			Npc[nIdx].GetMpsPos(&nDesX, &nDesY);
			Npc[m_nIndex].SendCommand(do_walk, nDesX, nDesY);	
		}
	}
	else
	{
		if (Npc[m_nIndex].m_CurrentCamp != camp_animal)
			Npc[m_nIndex].SetCurrentCamp(camp_animal);

		if (Npc[m_nIndex].m_uLastFindPathTime <= 0)
			Npc[m_nIndex].m_uLastFindPathTime = g_SubWorldSet.GetGameTime();
		else
		{
			if (g_SubWorldSet.GetGameTime() - Npc[m_nIndex].m_uLastFindPathTime > MAX_WAIT_PATH_NPC_TIME)
			{
				if (Npc[m_nIndex].m_RegionIndex >= 0)
				{
					SubWorld[Npc[m_nIndex].m_SubWorldIndex].m_Region[Npc[m_nIndex].m_RegionIndex].RemoveNpc(m_nIndex);
					SubWorld[Npc[m_nIndex].m_SubWorldIndex].m_Region[Npc[m_nIndex].m_RegionIndex].DecRef(Npc[m_nIndex].m_MapX, Npc[m_nIndex].m_MapY, obj_npc);
				}
				NpcSet.Remove(m_nIndex);
			}
		}
	}
}
#endif
//---------------------------------------------------------------------
// flying add these functions
// Run at client.
#ifndef _SERVER
// �����л���Ч����NPC
int KNpcAI::ProcessShowNpc()
{
    int nResult  = false;
    int nRetCode = false;

	switch (Npc[m_nIndex].m_AiMode)
	{
	// ������
	case 11:
		nRetCode = ShowNpcType11();
        if (!nRetCode)
            goto Exit0;
		break;
	// ������
	case 12:
		nRetCode = ShowNpcType12();
        if (!nRetCode)
            goto Exit0;
		break;
	// ������
	case 13:
		nRetCode = ShowNpcType13();
        if (!nRetCode)
            goto Exit0;
		break;
	// ������
	case 14:
		nRetCode = ShowNpcType14();
        if (!nRetCode)
            goto Exit0;
		break;
	// ��Ȯ��
	case 15:
		nRetCode = ShowNpcType15();
        if (!nRetCode)
            goto Exit0;
		break;
	// ������
	case 16:
		nRetCode = ShowNpcType16();
        if (!nRetCode)
            goto Exit0;
		break;
	// ������
	case 17:
		nRetCode = ShowNpcType17();
        if (!nRetCode)
            goto Exit0;
		break;
	default:
		break;
	}

    nResult = true;
Exit0:
	return nResult;
}
// ������
int KNpcAI::ShowNpcType11()
{
    int nResult = false;
    int nRetCode = false;

	KNpc& aNpc = Npc[m_nIndex];
	// Go the distance between P1 to P2	
	int nDistance = 0;
	int nDesX = 0;
	int nDesY = 0;
	int nCurX = 0;
	int nCurY = 0;
	int nOffX = 0;
	int nOffY = 0;
	int nOffsetDir = 0;
	
	// Ч����ǿ ��������߶�
	aNpc.m_Height = GetRandomNumber(aNpc.m_AiParam[6] - 4, aNpc.m_AiParam[6]);

	aNpc.GetMpsPos(&nCurX, &nCurY);

	// �����½Ƕ� �� ����
	if (aNpc.m_AiParam[3] > 0)
		nOffsetDir = GetRandomNumber(aNpc.m_AiParam[3], aNpc.m_AiParam[2]);
	else
		nOffsetDir = aNpc.m_AiParam[2];
	
    if (GetRandomNumber(0, 1))
		nOffsetDir = -nOffsetDir;
	
    nDistance = GetRandomNumber(aNpc.m_AiParam[0] - aNpc.m_AiParam[1], aNpc.m_AiParam[0]);

	// ȡ���˶������ʱ�䣬�����ڲ�������
	if (aNpc.m_CurrentWalkSpeed > 0)
	{
		aNpc.m_AiParam[4] = (int) nDistance / (int)aNpc.m_CurrentWalkSpeed;
		aNpc.m_AiParam[5] = 0;
	}
	//if (KeepActiveShowRange())
	//	aNpc.m_Dir += 32;
	aNpc.m_Dir += nOffsetDir;
	if (aNpc.m_Dir < 0)
		aNpc.m_Dir += 64;
	else
		aNpc.m_Dir %= 64;
	
    // �������Ǻ�������ƫ�Ƶ�X��Y��ֵ
	nRetCode = GetNpcMoveOffset(aNpc.m_Dir, nDistance, &nOffX, &nOffY);
    if (!nRetCode)
        goto Exit0;

	// ��ȡĿ������
	nDesX = nCurX + nOffX;
	nDesY = nCurY + nOffY;
	aNpc.SendCommand(do_walk, nDesX, nDesY);	

    nResult = true;
Exit0:
	return nResult;
}

// ������
// done
int KNpcAI::ShowNpcType12()
{
    int nResult = false;
    int nRetCode = false;

	// Go the distance between P1 to P2	
	int nDistance = 0;
	int nDesX = 0;
	int nDesY = 0;
	int nCurX = 0;
	int nCurY = 0;
	int nOffX = 0;
	int nOffY = 0;
	int nOffsetDir = 0;
	KNpc& aNpc = Npc[m_nIndex];

	// Ч����ǿ ��������߶�
	aNpc.m_Height = GetRandomNumber(aNpc.m_AiParam[6] - 4, aNpc.m_AiParam[6]);

	aNpc.GetMpsPos(&nCurX, &nCurY);
		
	// �����½Ƕ� �� ����
	if (aNpc.m_AiParam[3] > 0)
		nOffsetDir = GetRandomNumber(aNpc.m_AiParam[3], aNpc.m_AiParam[2]);
	else
		nOffsetDir = aNpc.m_AiParam[2];
	if (GetRandomNumber(0, 1))
		nOffsetDir = -nOffsetDir;
	nDistance = GetRandomNumber(aNpc.m_AiParam[0] - aNpc.m_AiParam[1], aNpc.m_AiParam[0]);

	// ȡ���˶������ʱ�䣬�����ڲ�������
	if (aNpc.m_CurrentWalkSpeed > 0)
	{
		aNpc.m_AiParam[4] = (int) nDistance / (int)aNpc.m_CurrentWalkSpeed;
		aNpc.m_AiParam[5] = 0;
	}
	else
	{
		aNpc.m_AiParam[4] = 0;
		aNpc.m_AiParam[5] = 0;
	}
	aNpc.m_Dir += nOffsetDir;
	if (aNpc.m_Dir < 0)
		aNpc.m_Dir += 64;
	else
		aNpc.m_Dir %= 64;

	// �������Ǻ�������ƫ�Ƶ�X��Y��ֵ
	nRetCode = GetNpcMoveOffset(aNpc.m_Dir, nDistance, &nOffX, &nOffY);
	if (!nRetCode)
		goto Exit0;
	// ��ȡĿ������
	nDesX = nCurX + nOffX;
	nDesY = nCurY + nOffY;
	aNpc.SendCommand(do_walk, nDesX, nDesY);

	nResult = true;
Exit0:
	return nResult;
}

// ������
// done
int KNpcAI::ShowNpcType13()
{
	int nResult  = false;
	int nRetCode = false;
	// Go the distance between P1 to P2	
	int nDistance = 0;
	int nDesX = 0;
	int nDesY = 0;
	int nCurX = 0;
	int nCurY = 0;
	int nOffX = 0;
	int nOffY = 0;
	int nOffsetDir = 0;
	int nIndex = 0;
	KNpc& aNpc = Npc[m_nIndex];

	aNpc.GetMpsPos(&nCurX, &nCurY);

	// �����½Ƕ� �� ����
	if (aNpc.m_AiParam[3] > 0)
		nOffsetDir = GetRandomNumber(aNpc.m_AiParam[3], aNpc.m_AiParam[2]);
	else
		nOffsetDir = aNpc.m_AiParam[2];
	if (GetRandomNumber(0, 1))
		nOffsetDir = -nOffsetDir;
	nDistance = GetRandomNumber(aNpc.m_AiParam[0] - aNpc.m_AiParam[1], aNpc.m_AiParam[0]);

	// ȡ���˶������ʱ�䣬�����ڲ�������
	if (aNpc.m_CurrentWalkSpeed > 0)
	{
		aNpc.m_AiParam[4] = (int) nDistance / (int)aNpc.m_CurrentWalkSpeed;
		aNpc.m_AiParam[5] = 0;
	}
	else
	{
		aNpc.m_AiParam[4] = 0;
		aNpc.m_AiParam[5] = 0;
	}
	//if (KeepActiveShowRange())
	//	aNpc.m_Dir += 32;
	// ���������
	nIndex = IsPlayerCome();
	if (nIndex > 0)
	{
		// do flee
		DoShowFlee(nIndex);
		goto Exit0;
	}
	// �������Ǻ�������ƫ�Ƶ�X��Y��ֵ
	nRetCode = GetNpcMoveOffset(aNpc.m_Dir, nDistance, &nOffX, &nOffY);
	// ��ȡĿ������
	nDesX = nCurX + nOffX;
	nDesY = nCurY + nOffY;
	aNpc.SendCommand(do_walk, nDesX, nDesY);

	nResult = true;
Exit0:
	return nResult;
}

// ������
// done
int KNpcAI::ShowNpcType14()
{
	int nResult  = false;
	int nRetCode = false;

	int nDistance = 0;
	int nDesX = 0;
	int nDesY = 0;
	int nCurX = 0;
	int nCurY = 0;
	int nOffX = 0;
	int nOffY = 0;
	int nRandom = 0;
	int nOffsetDir = 0;
	KNpc& aNpc = Npc[m_nIndex];

	nRandom = GetRandomNumber(1, 10);
	// ��ͷ����
	if (nRandom < 4)
		nDistance = -nDistance;
	// �໷���
	else if (nRandom < 7)
	{
		aNpc.SendCommand(do_stand);
		goto Exit0;
	}
	aNpc.GetMpsPos(&nCurX, &nCurY);
	// �����½Ƕ� �� ����
	if (aNpc.m_AiParam[3] > 0)
		nOffsetDir = GetRandomNumber(aNpc.m_AiParam[3], aNpc.m_AiParam[2]);
	else
		nOffsetDir = aNpc.m_AiParam[2];
	if (GetRandomNumber(0, 1))
		nOffsetDir = -nOffsetDir;
	nDistance = GetRandomNumber(aNpc.m_AiParam[0] - aNpc.m_AiParam[1], aNpc.m_AiParam[0]);
	// ȡ���˶������ʱ�䣬�����ڲ�������
	if (aNpc.m_CurrentWalkSpeed > 0)
	{
		aNpc.m_AiParam[4] = (int) nDistance / (int)aNpc.m_CurrentWalkSpeed;
		aNpc.m_AiParam[5] = 0;
	}
	else
	{
		aNpc.m_AiParam[4] = 0;
		aNpc.m_AiParam[5] = 0;
	}

	aNpc.m_Dir += nOffsetDir;
	if (aNpc.m_Dir < 0)
		aNpc.m_Dir += 64;
	else
		aNpc.m_Dir %= 64;
	// �������Ǻ�������ƫ�Ƶ�X��Y��ֵ
	nRetCode = GetNpcMoveOffset(aNpc.m_Dir, nDistance, &nOffX, &nOffY);
	if (!nRetCode)
		goto Exit0;
	// ��ȡĿ������
	nDesX = nCurX + nOffX;
	nDesY = nCurY + nOffY;
	aNpc.SendCommand(do_walk, nDesX, nDesY);

	nResult = true;
Exit0:
	return nResult;
}

// ��Ȯ��
int KNpcAI::ShowNpcType15()
{
	int nResult  = false;
	int nRetCode = false;
	// Go the distance between P1 to P2	
	int nDistance = 0;
	int nDesX = 0;
	int nDesY = 0;
	int nCurX = 0;
	int nCurY = 0;
	int nOffX = 0;
	int nOffY = 0;
	int nOffsetDir = 0;
	int nIndex = 0;
	KNpc& aNpc = Npc[m_nIndex];

	aNpc.GetMpsPos(&nCurX, &nCurY);

	// �����½Ƕ� �� ����
	if (aNpc.m_AiParam[3] > 0)
		nOffsetDir = GetRandomNumber(aNpc.m_AiParam[3], aNpc.m_AiParam[2]);
	else
		nOffsetDir = aNpc.m_AiParam[2];
	if (GetRandomNumber(0, 1))
		nOffsetDir = -nOffsetDir;
	nDistance = GetRandomNumber(aNpc.m_AiParam[0] - aNpc.m_AiParam[1], aNpc.m_AiParam[0]);

	// ȡ���˶������ʱ�䣬�����ڲ�������
	if (aNpc.m_CurrentWalkSpeed > 0)
	{
		aNpc.m_AiParam[4] = (int) nDistance / (int)aNpc.m_CurrentWalkSpeed;
		aNpc.m_AiParam[5] = 0;
	}
	else
	{
		aNpc.m_AiParam[4] = 0;
		aNpc.m_AiParam[5] = 0;
	}
	//if (KeepActiveShowRange())
	//	aNpc.m_Dir += 32;
	// ���������
	nIndex = IsPlayerCome();
	if (nIndex > 0)
	{
		// do flee
		DoShowFlee(nIndex);
		goto Exit0;
	}
	// �������Ǻ�������ƫ�Ƶ�X��Y��ֵ
	nRetCode = GetNpcMoveOffset(aNpc.m_Dir, nDistance, &nOffX, &nOffY);
	// ��ȡĿ������
	nDesX = nCurX + nOffX;
	nDesY = nCurY + nOffY;
	aNpc.SendCommand(do_walk, nDesX, nDesY);

	nResult = true;
Exit0:
	return nResult;
}

// ������
int KNpcAI::ShowNpcType16()
{
	int nResult  = false;
	int nRetCode = false;

	// Go the distance between P1 to P2
	register int nDistance = 0;
	int nDesX = 0;
	int nDesY = 0;
	int nCurX = 0;
	int nCurY = 0;
	int nOffX = 0;
	int nOffY = 0;
	int nOffsetDir = 0;
	int nIndex = 0;
	KNpc& aNpc = Npc[m_nIndex];

	aNpc.GetMpsPos(&nCurX, &nCurY);

	// �����½Ƕ� �� ����
	if (aNpc.m_AiParam[3] > 0)
		nOffsetDir = GetRandomNumber(aNpc.m_AiParam[3], aNpc.m_AiParam[2]);
	else
		nOffsetDir = aNpc.m_AiParam[2];
	if (GetRandomNumber(0, 1))
		nOffsetDir = -nOffsetDir;
	nDistance = GetRandomNumber(aNpc.m_AiParam[0] - aNpc.m_AiParam[1], aNpc.m_AiParam[0]);
	// ���������
	nIndex = IsPlayerCome();
	if (nIndex > 0)
	{
		// do flee
		nRetCode = DoShowFlee(nIndex);
		if (!nRetCode)
			goto Exit0;		
		goto Exit1;
	}

	// �������
	if (aNpc.m_CurrentWalkSpeed > 0)
	{
		aNpc.m_AiParam[4] = (int) nDistance / (int)aNpc.m_CurrentWalkSpeed;
		aNpc.m_AiParam[5] = 0;
	}
	else
	{
		aNpc.m_AiParam[4] = 0;
		aNpc.m_AiParam[5] = 0;
	}

	// �����½Ƕ�
	//if (KeepActiveShowRange())
	//	aNpc.m_Dir += 32;
	aNpc.m_Dir += GetRandomNumber(0, 6);
	aNpc.m_Dir %= 64;
	// �������Ǻ�������ƫ�Ƶ�X��Y��ֵ
	nRetCode = GetNpcMoveOffset(aNpc.m_Dir, nDistance, &nOffX, &nOffY);
	if (!nRetCode)
		goto Exit0;
	// ��ȡĿ������
	nDesX = nCurX + nOffX;
	nDesY = nCurY + nOffY;
	aNpc.SendCommand(do_walk, nDesX, nDesY);

Exit1:	
	nResult = true;
Exit0:
	return nResult;
}

// ������
int KNpcAI::ShowNpcType17()
{
	int nResult  = false;
	int nRetCode = false;

	// Go the distance between P1 to P2
	int nDistance = 0;
	int nDesX = 0;
	int nDesY = 0;
	int nCurX = 0;
	int nCurY = 0;
	int nOffX = 0;
	int nOffY = 0;
	int nOffsetDir = 0;
	KNpc& aNpc = Npc[m_nIndex];

	// Ч����ǿ ��������߶�
	aNpc.m_Height = GetRandomNumber(aNpc.m_AiParam[6] - 4, aNpc.m_AiParam[6]);

	aNpc.GetMpsPos(&nCurX, &nCurY);
		
	// �����½Ƕ� �� ����
	if (aNpc.m_AiParam[3] > 0)
		nOffsetDir = GetRandomNumber(aNpc.m_AiParam[3], aNpc.m_AiParam[2]);
	else
		nOffsetDir = aNpc.m_AiParam[2];
	if (GetRandomNumber(0, 1))
		nOffsetDir = -nOffsetDir;
	nDistance = GetRandomNumber(aNpc.m_AiParam[0] - aNpc.m_AiParam[1], aNpc.m_AiParam[0]);	

	// ȡ���˶������ʱ�䣬�����ڲ�������
	if (aNpc.m_CurrentWalkSpeed > 0)
	{
		aNpc.m_AiParam[4] = (int) nDistance / (int)aNpc.m_CurrentWalkSpeed;
		aNpc.m_AiParam[5] = 0;
	}
	else
	{
		aNpc.m_AiParam[4] = 0;
		aNpc.m_AiParam[5] = 0;
	}
	if (KeepActiveRange())
	{
		//aNpc.SendCommand(do_walk, aNpc.m_OriginX, aNpc.m_OriginY);
		goto Exit0;
		//aNpc.m_Dir += 32;
	}
	aNpc.m_Dir += nOffsetDir;
	//aNpc.m_Dir += GetRandomNumber(32, 64);
	if (aNpc.m_Dir < 0)
		aNpc.m_Dir += 64;
	else
		aNpc.m_Dir %= 64;
	// �������Ǻ�������ƫ�Ƶ�X��Y��ֵ
	nRetCode = GetNpcMoveOffset(aNpc.m_Dir, nDistance, &nOffX, &nOffY);
	if (!nRetCode)
		goto Exit0;
	// ��ȡĿ������
	nDesX = nCurX + nOffX;
	nDesY = nCurY + nOffY;
	aNpc.SendCommand(do_walk, nDesX, nDesY);
	
	nResult = true;
Exit0:
	return nResult;
}
#endif
//---------------------------------------------------------------------
// Player AI add here.
// flying comment
void KNpcAI::ProcessPlayer()
{
#ifdef _SERVER
	TriggerObjectTrap();
	TriggerMapTrap();
#else
	int i = Npc[m_nIndex].m_nPeopleIdx;
	if (i > 0)
	{
		FollowPeople(i);
	}
	i = Npc[m_nIndex].m_nObjectIdx;
	if (i > 0)
	{
		FollowObject(i);
	}
#endif
}

#ifndef _SERVER
void KNpcAI::FollowObject(int nIdx)
{
	int nX1, nY1, nX2, nY2;
	Npc[m_nIndex].GetMpsPos(&nX1, &nY1);
	Object[nIdx].GetMpsPos(&nX2, &nY2);

	if ((nX1 - nX2) * (nX1 - nX2) + (nY1 - nY2) * (nY1 - nY2) < PLAYER_PICKUP_CLIENT_DISTANCE * PLAYER_PICKUP_CLIENT_DISTANCE)
	{
//#ifndef _SERVER
		Player[CLIENT_PLAYER_INDEX].CheckObject(nIdx);
//#endif
	}
}
#endif

BOOL KNpcAI::CheckNpc(int nIndex)
{
	if (nIndex <= 0 || nIndex >= MAX_NPC ||
		Npc[nIndex].m_RegionIndex < 0 ||
		Npc[nIndex].m_HideState.nTime > 0)
	{
		return TRUE;
	}

	// Region_S dialog NPCs may not carry combat life values. They remain valid
	// interaction targets even when CurrentLifeMax is zero.
	if (Npc[nIndex].m_Kind == kind_dialoger)
		return FALSE;

	if (Npc[nIndex].m_CurrentLifeMax <= 0 || !Npc[nIndex].IsAlive())
		return TRUE;

	return FALSE;
}

#ifndef _SERVER
void KNpcAI::FollowPeople(int nIdx)
{
	if (CheckNpc(nIdx))
	{
		Npc[m_nIndex].m_nPeopleIdx = 0;
		return;
	}

	// ȡ�õ�Ŀ��ľ���
	int distance = NpcSet.GetDistance(nIdx, m_nIndex);
	int	nRelation = NpcSet.GetRelation(m_nIndex, nIdx);

	// С�ڶԻ��뾶�Ϳ�ʼ�Ի�
	if ((Npc[nIdx].m_Kind == kind_dialoger))
	{
		if (distance <= Npc[nIdx].m_DialogRadius)
		{
			int x, y;
			SubWorld[Npc[m_nIndex].m_SubWorldIndex].Map2Mps(Npc[m_nIndex].m_RegionIndex, Npc[m_nIndex].m_MapX, Npc[m_nIndex].m_MapY, Npc[m_nIndex].m_OffX, Npc[m_nIndex].m_OffY, &x, &y);
			Npc[m_nIndex].SendCommand(do_walk, x,y);
			SendClientCmdWalk(x, y);
			Player[CLIENT_PLAYER_INDEX].DialogNpc(nIdx);
			Npc[Player[CLIENT_PLAYER_INDEX].m_nIndex].m_nPeopleIdx = 0;
			Npc[nIdx].TurnTo(Player[CLIENT_PLAYER_INDEX].m_nIndex);
			return;
		}
	}
	// ����С�ڹ�����Χ�Ϳ�ʼ����
	if (nRelation == relation_enemy)
	{




	ISkill * pSkillCheck = Npc[m_nIndex].GetActiveSkill();
	if(pSkillCheck)
	{

	if (pSkillCheck->GetAttackRadius() >= Npc[m_nIndex].m_CurrentAttackRadius)
	{


		if (distance <= Npc[m_nIndex].m_CurrentAttackRadius)
		{
			Npc[m_nIndex].SendCommand(do_skill, Npc[m_nIndex].m_ActiveSkillID, -1, nIdx);

			// Send to Server
			int nX0,nY0;
			Npc[m_nIndex].GetMpsPos(&nX0,&nY0);
SendClientCmdSkill(Npc[m_nIndex].m_ActiveSkillID, -1, Npc[nIdx].m_dwID);
		}
		// ��׷
		else
		{
			int nDesX, nDesY;
			Npc[nIdx].GetMpsPos(&nDesX, &nDesY);
			// modify by spe 2003/06/13
			if (Player[CLIENT_PLAYER_INDEX].m_RunStatus)
			{
				Npc[m_nIndex].SendCommand(do_run, nDesX, nDesY);			
				SendClientCmdRun(nDesX, nDesY);
			}
			else
			{
				Npc[m_nIndex].SendCommand(do_walk, nDesX, nDesY);
				SendClientCmdWalk(nDesX, nDesY);
			}
		}



	}

	}



		return;
	}
	// ����
	if (Npc[nIdx].m_Kind == kind_player)
	{
		// flow
		int nDesX, nDesY;
		if (distance < MAX_FOLLOW_DISTANCE)
		{
			Npc[this->m_nIndex].GetMpsPos(&nDesX, &nDesY);
			Npc[m_nIndex].SendCommand(do_walk, nDesX, nDesY);
			SendClientCmdWalk(nDesX, nDesY);
		}
		else
		{
			Npc[nIdx].GetMpsPos(&nDesX, &nDesY);
			if (distance < FOLLOW_WALK_DISTANCE ||
				!Player[CLIENT_PLAYER_INDEX].m_RunStatus)
			{
				Npc[m_nIndex].SendCommand(do_walk, nDesX, nDesY);
				SendClientCmdWalk(nDesX, nDesY);
			}
			else
			{
				Npc[m_nIndex].SendCommand(do_run, nDesX, nDesY);			
				SendClientCmdRun(nDesX, nDesY);
			}
		}
	}
	return;
}
#endif

void KNpcAI::TriggerMapTrap()
{
    int nDesX, nDesY;
    Npc[m_nIndex].GetMpsPos(&nDesX, &nDesY);
	Npc[m_nIndex].CheckTrap(nDesX,nDesY);
}


void KNpcAI::TriggerObjectTrap()
{
	return;
}

int KNpcAI::GetNearestNpc(int nRelation)
{
	int nRangeX = Npc[m_nIndex].m_VisionRadius;
	int	nRangeY = nRangeX;
	int	nSubWorld = Npc[m_nIndex].m_SubWorldIndex;
	int	nRegion = Npc[m_nIndex].m_RegionIndex;
	int	nMapX = Npc[m_nIndex].m_MapX;
	int	nMapY = Npc[m_nIndex].m_MapY;
	int	nRet;
	int	nRMx, nRMy, nSearchRegion;

	nRangeX = nRangeX / SubWorld[nSubWorld].m_nCellWidth;
	nRangeY = nRangeY / SubWorld[nSubWorld].m_nCellHeight;	

	// �����Ұ��Χ�ڵĸ������NPC
	for (int i = 0; i < nRangeX; i++)	// i, j��0��ʼ�����Ǵ�-range��ʼ��Ҫ��֤Nearest
	{
		for (int j = 0; j < nRangeY; j++)
		{
			// ȥ���߽Ǽ������ӣ���֤��Ұ����Բ��
			if ((i * i + j * j) > nRangeX * nRangeX)
				continue;

			// ȷ��Ŀ�����ʵ�ʵ�REGION������ȷ��
			nRMx = nMapX + i;
			nRMy = nMapY + j;
			nSearchRegion = nRegion;
			if (nRMx < 0)
			{
				nSearchRegion = SubWorld[nSubWorld].m_Region[nSearchRegion].m_nConnectRegion[2];
				nRMx += SubWorld[nSubWorld].m_nRegionWidth;
			}
			else if (nRMx >= SubWorld[nSubWorld].m_nRegionWidth)
			{
				nSearchRegion = SubWorld[nSubWorld].m_Region[nSearchRegion].m_nConnectRegion[6];
				nRMx -= SubWorld[nSubWorld].m_nRegionWidth;
			}
			if (nSearchRegion == -1)
				continue;
			if (nRMy < 0)
			{
				nSearchRegion = SubWorld[nSubWorld].m_Region[nSearchRegion].m_nConnectRegion[4];
				nRMy += SubWorld[nSubWorld].m_nRegionHeight;
			}
			else if (nRMy >= SubWorld[nSubWorld].m_nRegionHeight)
			{
				nSearchRegion = SubWorld[nSubWorld].m_Region[nSearchRegion].m_nConnectRegion[0];
				nRMy -= SubWorld[nSubWorld].m_nRegionHeight;
			}
			if (nSearchRegion == -1)
				continue;
			// ��REGION��NPC�б��в�������������NPC			
			nRet = SubWorld[nSubWorld].m_Region[nSearchRegion].FindNpc(nRMx, nRMy, m_nIndex, nRelation);
			if (Npc[nRet].m_HideState.nTime > 0)
				nRet = 0;
			if (nRet > 0)
				return nRet;	
			// ȷ��Ŀ�����ʵ�ʵ�REGION������ȷ��
			nRMx = nMapX - i;
			nRMy = nMapY + j;
			nSearchRegion = nRegion;
			if (nRMx < 0)
			{
				nSearchRegion = SubWorld[nSubWorld].m_Region[nSearchRegion].m_nConnectRegion[2];
				nRMx += SubWorld[nSubWorld].m_nRegionWidth;
			}
			else if (nRMx >= SubWorld[nSubWorld].m_nRegionWidth)
			{
				nSearchRegion = SubWorld[nSubWorld].m_Region[nSearchRegion].m_nConnectRegion[6];
				nRMx -= SubWorld[nSubWorld].m_nRegionWidth;
			}
			if (nSearchRegion == -1)
				continue;
			if (nRMy < 0)
			{
				nSearchRegion = SubWorld[nSubWorld].m_Region[nSearchRegion].m_nConnectRegion[4];
				nRMy += SubWorld[nSubWorld].m_nRegionHeight;
			}
			else if (nRMy >= SubWorld[nSubWorld].m_nRegionHeight)
			{
				nSearchRegion = SubWorld[nSubWorld].m_Region[nSearchRegion].m_nConnectRegion[0];
				nRMy -= SubWorld[nSubWorld].m_nRegionHeight;
			}
			if (nSearchRegion == -1)
				continue;
			// ��REGION��NPC�б��в�������������NPC			
			nRet = SubWorld[nSubWorld].m_Region[nSearchRegion].FindNpc(nRMx, nRMy, m_nIndex, nRelation);
			if (Npc[nRet].m_HideState.nTime > 0)
				nRet = 0;
			if (nRet > 0)
				return nRet;
			// ȷ��Ŀ�����ʵ�ʵ�REGION������ȷ��
			nRMx = nMapX - i;
			nRMy = nMapY - j;
			nSearchRegion = nRegion;
			if (nRMx < 0)
			{
				nSearchRegion = SubWorld[nSubWorld].m_Region[nSearchRegion].m_nConnectRegion[2];
				nRMx += SubWorld[nSubWorld].m_nRegionWidth;
			}
			else if (nRMx >= SubWorld[nSubWorld].m_nRegionWidth)
			{
				nSearchRegion = SubWorld[nSubWorld].m_Region[nSearchRegion].m_nConnectRegion[6];
				nRMx -= SubWorld[nSubWorld].m_nRegionWidth;
			}
			if (nSearchRegion == -1)
				continue;
			if (nRMy < 0)
			{
				nSearchRegion = SubWorld[nSubWorld].m_Region[nSearchRegion].m_nConnectRegion[4];
				nRMy += SubWorld[nSubWorld].m_nRegionHeight;
			}
			else if (nRMy >= SubWorld[nSubWorld].m_nRegionHeight)
			{
				nSearchRegion = SubWorld[nSubWorld].m_Region[nSearchRegion].m_nConnectRegion[0];
				nRMy -= SubWorld[nSubWorld].m_nRegionHeight;
			}
			if (nSearchRegion == -1)
				continue;
			// ��REGION��NPC�б��в�������������NPC			
			nRet = SubWorld[nSubWorld].m_Region[nSearchRegion].FindNpc(nRMx, nRMy, m_nIndex, nRelation);
			if (Npc[nRet].m_HideState.nTime > 0)
				nRet = 0;
			if (nRet > 0)
				return nRet;
			// ȷ��Ŀ�����ʵ�ʵ�REGION������ȷ��
			nRMx = nMapX + i;
			nRMy = nMapY - j;
			nSearchRegion = nRegion;			
			if (nRMx < 0)
			{
				nSearchRegion = SubWorld[nSubWorld].m_Region[nSearchRegion].m_nConnectRegion[2];
				nRMx += SubWorld[nSubWorld].m_nRegionWidth;
			}
			else if (nRMx >= SubWorld[nSubWorld].m_nRegionWidth)
			{
				nSearchRegion = SubWorld[nSubWorld].m_Region[nSearchRegion].m_nConnectRegion[6];
				nRMx -= SubWorld[nSubWorld].m_nRegionWidth;
			}
			if (nSearchRegion == -1)
				continue;
			if (nRMy < 0)
			{
				nSearchRegion = SubWorld[nSubWorld].m_Region[nSearchRegion].m_nConnectRegion[4];
				nRMy += SubWorld[nSubWorld].m_nRegionHeight;
			}
			else if (nRMy >= SubWorld[nSubWorld].m_nRegionHeight)
			{
				nSearchRegion = SubWorld[nSubWorld].m_Region[nSearchRegion].m_nConnectRegion[0];
				nRMy -= SubWorld[nSubWorld].m_nRegionHeight;
			}
			if (nSearchRegion == -1)
				continue;
			// ��REGION��NPC�б��в�������������NPC
			nRet = SubWorld[nSubWorld].m_Region[nSearchRegion].FindNpc(nRMx, nRMy, m_nIndex, nRelation);
			if (Npc[nRet].m_HideState.nTime > 0)
				nRet = 0;
			if (nRet > 0)
				return nRet;
		}
	}
	return 0;
}

#ifndef _SERVER
// flying add this
// ������ĳ��NPC��������
int KNpcAI::IsPlayerCome()
{
	int nResult = 0;
	int nPlayer = 0;
	int X1 = 0;
	int Y1 = 0;
	int X2 = 0;
	int Y2 = 0;
	int distance = 0;

	nPlayer = Player[CLIENT_PLAYER_INDEX].m_nIndex;
	distance = NpcSet.GetDistance(nPlayer, m_nIndex);
	// �����ĵ������
	if (distance < Npc[m_nIndex].m_VisionRadius)
	{
		// �ֱ����ߺ���
		if (Player[CLIENT_PLAYER_INDEX].m_RunStatus ||
			Npc[m_nIndex].m_CurrentVisionRadius > distance * 4)
		{
			nResult = nPlayer;
		}
	}
	return nResult;
}
#endif

int KNpcAI::GetNpcNumber(int nRelation)
{
	int nRangeX = Npc[m_nIndex].m_VisionRadius;
	int	nRangeY = nRangeX;
	int	nSubWorld = Npc[m_nIndex].m_SubWorldIndex;
	int	nRegion = Npc[m_nIndex].m_RegionIndex;
	int	nMapX = Npc[m_nIndex].m_MapX;
	int	nMapY = Npc[m_nIndex].m_MapY;
	int	nRet = 0;
	int	nRMx, nRMy, nSearchRegion;

	nRangeX = nRangeX / SubWorld[nSubWorld].m_nCellWidth;
	nRangeY = nRangeY / SubWorld[nSubWorld].m_nCellHeight;

	// �����Ұ��Χ�ڵĸ������NPC
	for (int i = -nRangeX; i < nRangeX; i++)
	{
		for (int j = -nRangeY; j < nRangeY; j++)
		{
			// ȥ���߽Ǽ������ӣ���֤��Ұ����Բ��
			if ((i * i + j * j) > nRangeX * nRangeX)
				continue;

			// ȷ��Ŀ�����ʵ�ʵ�REGION������ȷ��
			nRMx = nMapX + i;
			nRMy = nMapY + j;
			nSearchRegion = nRegion;
			if (nRMx < 0)
			{
				nSearchRegion = SubWorld[nSubWorld].m_Region[nSearchRegion].m_nConnectRegion[2];
				nRMx += SubWorld[nSubWorld].m_nRegionWidth;
			}
			else if (nRMx >= SubWorld[nSubWorld].m_nRegionWidth)
			{
				nSearchRegion = SubWorld[nSubWorld].m_Region[nSearchRegion].m_nConnectRegion[6];
				nRMx -= SubWorld[nSubWorld].m_nRegionWidth;
			}
			if (nSearchRegion == -1)
				continue;
			if (nRMy < 0)
			{
				nSearchRegion = SubWorld[nSubWorld].m_Region[nSearchRegion].m_nConnectRegion[4];
				nRMy += SubWorld[nSubWorld].m_nRegionHeight;
			}
			else if (nRMy >= SubWorld[nSubWorld].m_nRegionHeight)
			{
				nSearchRegion = SubWorld[nSubWorld].m_Region[nSearchRegion].m_nConnectRegion[0];
				nRMy -= SubWorld[nSubWorld].m_nRegionHeight;
			}
			if (nSearchRegion == -1)
				continue;
			// ��REGION��NPC�б��в�������������NPC			
			int nNpcIdx = SubWorld[nSubWorld].m_Region[nSearchRegion].FindNpc(nRMx, nRMy, m_nIndex, nRelation);
			if (nNpcIdx > 0)
				nRet++;
		}
	}
	return nRet;
}

void KNpcAI::KeepAttackRange(int nEnemy, int nRange)
{
	int nX1, nY1, nX2, nY2, nDir, nWantX, nWantY;

	Npc[m_nIndex].GetMpsPos(&nX1, &nY1);
	Npc[nEnemy].GetMpsPos(&nX2, &nY2);
	nDir = g_GetDirIndex(nX1, nY1, nX2, nY2);

	nWantX = nX2 - ((nRange * g_DirCos(nDir, 64)) >> 10);
	nWantY = nY2 - ((nRange * g_DirSin(nDir, 64)) >> 10);

	Npc[m_nIndex].SendCommand(do_walk, nWantX, nWantY);
}

void KNpcAI::FollowAttack(int i)
{
	if (CheckNpc(i))
		return;
	
	if ( Npc[i].m_RegionIndex < 0 )
		return;

	int distance = NpcSet.GetDistance(m_nIndex, i);
#define	MINI_ATTACK_RANGE	32

	if (distance <= MINI_ATTACK_RANGE)
	{
		KeepAttackRange(i, MINI_ATTACK_RANGE);
		return;
	}
	// Attack Enemy
	if (distance <= Npc[m_nIndex].m_CurrentAttackRadius && InEyeshot(i))
	{
		ISkill * pISkill =  g_SkillManager.GetSkill(Npc[m_nIndex].m_ActiveSkillID, 1);
		if (!pISkill) 
            return;
		if (pISkill->IsAura())
			return;

		if (pISkill->GetSkillStyle() == SKILL_SS_Missles && (pISkill->IsTargetAlly() || pISkill->IsTargetSelf()))
		{
			int nX;
			int nY;
			Npc[m_nIndex].GetMpsPos(&nX, &nY);
			Npc[m_nIndex].SendCommand(do_skill, Npc[m_nIndex].m_ActiveSkillID, nX, nY);
			return;
		}
		Npc[m_nIndex].SendCommand(do_skill, Npc[m_nIndex].m_ActiveSkillID, -1, i);
		return;
	}

	// Move to Enemy
	int x, y;
	Npc[i].GetMpsPos(&x, &y);

	Npc[m_nIndex].SendCommand(do_walk, x, y);
}

BOOL KNpcAI::InEyeshot(int nIdx)
{
	int distance = NpcSet.GetDistance(nIdx, m_nIndex);
	return (Npc[m_nIndex].m_VisionRadius > distance);
}

void KNpcAI::CommonAction()
{
	// ����ǶԻ����NPC����ԭ�ز���
	if (Npc[m_nIndex].m_Kind == kind_dialoger)
	{
		if (Npc[m_nIndex].m_Doing != do_stand)
			Npc[m_nIndex].SendCommand(do_stand);
		return;
	}
	int	nOffX, nOffY;
	if (g_RandPercent(80))
	{
		nOffX = 0;
		nOffY = 0;
	}
	else
	{
		
		nOffX = g_Random(Npc[m_nIndex].m_CurrentActiveRadius / 2);
		nOffY = g_Random(Npc[m_nIndex].m_CurrentActiveRadius / 2);
		if (nOffX & 1)
		{
			nOffX = - nOffX;
		}
		if (nOffY & 1)
		{
			nOffY = - nOffY;
		}
	}
	Npc[m_nIndex].SendCommand(do_walk, Npc[m_nIndex].m_OriginX + nOffX, Npc[m_nIndex].m_OriginY + nOffY);
}

BOOL KNpcAI::KeepActiveRange()
{
	int x, y;
	
	Npc[m_nIndex].GetMpsPos(&x, &y);
	int	nRange = g_GetDistance(Npc[m_nIndex].m_OriginX, Npc[m_nIndex].m_OriginY, x, y);

	// ���ֳ������Χ���ѵ�ǰ���Χ��С�������ڻ��Χ��Ե���ػΡ�
	if (Npc[m_nIndex].m_ActiveRadius < nRange)
	{
		Npc[m_nIndex].m_CurrentActiveRadius = Npc[m_nIndex].m_ActiveRadius / 2;
	}

	// ���ֳ�����ǰ���Χ��������
	if (Npc[m_nIndex].m_CurrentActiveRadius < nRange)
	{
		Npc[m_nIndex].SendCommand(do_walk, Npc[m_nIndex].m_OriginX, Npc[m_nIndex].m_OriginY);
		return TRUE;
	}
	else	// �ڵ�ǰ���Χ�ڣ��ָ���ǰ���Χ��С��
	{
		Npc[m_nIndex].m_CurrentActiveRadius = Npc[m_nIndex].m_ActiveRadius;
		return FALSE;
	}
}
BOOL KNpcAI::KeepActiveRangeOwern()
{
	int x, y;
	int x1, y1;
	int m_nOwnerIdx = Npc[m_nIndex].m_nOwnerIdx;

	Npc[m_nIndex].GetMpsPos(&x, &y);
	Npc[m_nOwnerIdx].GetMpsPos(&x1, &y1);
	int	nRange = g_GetDistance(x1, y1, x, y);

	if (nRange > 250)
	{
		Npc[m_nIndex].SendCommand(do_run, x1, y1);
		return TRUE;
	}else{
		return FALSE;
	}
	
}
#ifndef _SERVER
// 15/16 AiMode NPC�����ݶ���
int KNpcAI::DoShowFlee(int nIdx)
{
	int nResult  = false;
	int nRetCode = false;
	
	int x1, y1, x2, y2;
	int nDistance = Npc[m_nIndex].m_AiParam[6];

	Npc[m_nIndex].GetMpsPos(&x1, &y1);
	//Npc[nIdx].GetMpsPos(&x2, &y2);
	Npc[m_nIndex].m_Dir = Npc[nIdx].m_Dir;
	nRetCode = GetNpcMoveOffset(Npc[m_nIndex].m_Dir, nDistance, &x2, &y2);
	if (!nRetCode)
		goto Exit0;
	Npc[m_nIndex].m_AiParam[4] = (int) nDistance / Npc[m_nIndex].m_WalkSpeed;
	Npc[m_nIndex].m_AiParam[5] = 0;
	Npc[m_nIndex].SendCommand(do_walk, x1 + x2, y1 + y2);

	nResult = true;
Exit0:
	return nResult;
}

#endif

// ����Npc[nIdx]
void KNpcAI::Flee(int nIdx)
{
	int x1, y1, x2, y2;

	Npc[m_nIndex].GetMpsPos(&x1, &y1);
	Npc[nIdx].GetMpsPos(&x2, &y2);

	x1 = x1 * 2 - x2;
	y1 = y1 * 2 - y2;

	Npc[m_nIndex].SendCommand(do_walk, x1, y1);
}
//------------------------------------------------------------------------------
//	���ܣ���ͨ������1
//	m_AiParam[0] �޵���ʱ���Ѳ�߸���
//	m_AiParam[1��2��3��4] ���ּ��ܵ�ʹ�ø��ʣ��ֱ��ӦSkillList��ļ���1 2 3 4
//	m_AiParam[5��6] �������˵��Ƚ�Զʱ��������Ѳ�ߵĸ���
//------------------------------------------------------------------------------
void	KNpcAI::ProcessAIType01()
{
	int *pAIParam = Npc[m_nIndex].m_AiParam;
	// �Ƿ��ѳ�����뾶
	if (KeepActiveRange())
		return;

	int nEnemyIdx = Npc[m_nIndex].m_nPeopleIdx;
	// ���ԭ��û���������˻������������̫Զ��������������
	if (nEnemyIdx <= 0 || Npc[nEnemyIdx].m_dwID <= 0 || !InEyeshot(nEnemyIdx) )
	{
		nEnemyIdx = GetNearestNpc(relation_enemy);
		Npc[m_nIndex].m_nPeopleIdx = nEnemyIdx;
	}

	// ��Χû�е��ˣ�һ�����ʴ���/Ѳ��
	if (nEnemyIdx <= 0)
	{
		// pAIParam[0]:Ѳ�߸���
		if (pAIParam[0] > 0 && g_RandPercent(pAIParam[0]))
		{	// Ѳ��
			CommonAction();
		}
		return;
	}

	// ������������м��ܹ�����Χ֮�⣬һ������ѡ�����/Ѳ��/����˿���
	if (KNpcSet::GetDistanceSquare(m_nIndex, nEnemyIdx) > pAIParam[MAX_AI_PARAM - 1])
	{
		int		nRand;
		nRand = g_Random(100);
		if (nRand < pAIParam[5])	// ����
			return;
		if (nRand < pAIParam[5] + pAIParam[6])	// Ѳ��
		{
			CommonAction();
			return;
		}
		FollowAttack(nEnemyIdx);	// ����˿���
		return;
	}

	// ����������ܹ�����Χ֮�ڣ�ѡ��һ�ּ��ܹ���
	int		nRand;
	nRand = g_Random(100);
	if (nRand < pAIParam[1])
	{
		if (!Npc[m_nIndex].SetActiveSkill(1))
		{
			CommonAction();
			return;
		}
	}
	else if (nRand < pAIParam[1] + pAIParam[2])
	{
		if (!Npc[m_nIndex].SetActiveSkill(2))
		{
			CommonAction();
			return;
		}
	}
	else if (nRand < pAIParam[1] + pAIParam[2] + pAIParam[3])
	{
		if (!Npc[m_nIndex].SetActiveSkill(3))
		{
			CommonAction();
			return;
		}
	}
	else if (nRand < pAIParam[1] + pAIParam[2] + pAIParam[3] + pAIParam[4])
	{
		if (!Npc[m_nIndex].SetActiveSkill(4))
		{
			CommonAction();
			return;
		}
	}
	else	// ����
	{
		return;
	}

	FollowAttack(nEnemyIdx);
}


//------------------------------------------------------------------------------
//	���ܣ���ͨ������2
//	m_AiParam[0] �޵���ʱ���Ѳ�߸���
//	m_AiParam[1] ʣ��������������ٷֱȵ�ʱ��ִ����Ӧ����
//	m_AiParam[2] ��m_AiParam[1]��������ֵ�ʱ���Ƿ�ִ����Ӧ�����ĸ���
//	m_AiParam[3] ��m_AiParam[1]��������ֲ�����Ҫִ����Ӧ������ʹ�ûظ����ܵĸ��� ��ӦSkillList����ļ��� 1
//	m_AiParam[4��5��6] ���ֹ������ܵ�ʹ�ø��ʣ��ֱ��ӦSkillList��ļ��� 2 3 4
//	m_AiParam[7��8] �������˵��Ƚ�Զʱ��������Ѳ�ߵĸ���
//------------------------------------------------------------------------------
void	KNpcAI::ProcessAIType02()
{
	int *pAIParam = Npc[m_nIndex].m_AiParam;
	// �Ƿ��ѳ�����뾶
	if (KeepActiveRange())
		return;

	int nEnemyIdx = Npc[m_nIndex].m_nPeopleIdx;
	// ���ԭ��û���������˻������������̫Զ��������������
	if (nEnemyIdx <= 0 || Npc[nEnemyIdx].m_dwID <= 0 || !InEyeshot(nEnemyIdx) )
	{
		nEnemyIdx = GetNearestNpc(relation_enemy);
		Npc[m_nIndex].m_nPeopleIdx = nEnemyIdx;
	}

	// ��Χû�е��ˣ�һ�����ʴ���/Ѳ��
	if (nEnemyIdx <= 0)
	{
		// pAIParam[0]:Ѳ�߸���
		if (pAIParam[0] > 0 && g_RandPercent(pAIParam[0]))
		{	// Ѳ��
			CommonAction();
		}
		return;
	}

	// ���ʣ�������Ƿ��������������̫��һ������ʹ�ò�Ѫ���ܻ�����
	if (Npc[m_nIndex].m_CurrentLife * 100 / Npc[m_nIndex].m_CurrentLifeMax < pAIParam[1])
	{
		if (g_RandPercent(pAIParam[2]))	// �Ƿ�ʹ�ò�Ѫ���ܻ�����
		{
			if (Npc[m_nIndex].m_AiAddLifeTime < pAIParam[9] && g_RandPercent(pAIParam[3]))	// ʹ�ò�Ѫ����
			{
				Npc[m_nIndex].SetActiveSkill(1);
				Npc[m_nIndex].SendCommand(do_skill, Npc[m_nIndex].m_ActiveSkillID, -1, m_nIndex);
				Npc[m_nIndex].m_AiAddLifeTime++;
				return;
			}
			else	// ����
			{
				Flee(nEnemyIdx);
				return;
			}
		}
	}

	// ������������м��ܹ�����Χ֮�⣬һ������ѡ�����/Ѳ��/����˿���
	if (KNpcSet::GetDistanceSquare(m_nIndex, nEnemyIdx) > pAIParam[MAX_AI_PARAM - 1])
	{
		int		nRand;
		nRand = g_Random(100);
		if (nRand < pAIParam[7])	// ����
			return;
		if (nRand < pAIParam[7] + pAIParam[8])	// Ѳ��
		{
			CommonAction();
			return;
		}
		FollowAttack(nEnemyIdx);	// ����˿���
		return;
	}

	// ����������ܹ�����Χ֮�ڣ�ѡ��һ�ּ��ܹ���
	int		nRand;
	nRand = g_Random(100);
	if (nRand < pAIParam[4])
	{
		if (!Npc[m_nIndex].SetActiveSkill(2))
		{
			CommonAction();
			return;
		}
	}
	else if (nRand < pAIParam[4] + pAIParam[5])
	{
		if (!Npc[m_nIndex].SetActiveSkill(3))
		{
			CommonAction();
			return;
		}
	}
	else if (nRand < pAIParam[4] + pAIParam[5] + pAIParam[6])
	{
		if (!Npc[m_nIndex].SetActiveSkill(4))
		{
			CommonAction();
			return;
		}
	}
	else	// ����
	{
		return;
	}
	FollowAttack(nEnemyIdx);
}

//------------------------------------------------------------------------------
//	���ܣ���ͨ������3
//	m_AiParam[0] �޵���ʱ���Ѳ�߸���
//	m_AiParam[1] ʣ��������������ٷֱȵ�ʱ��ִ����Ӧ����
//	m_AiParam[2] ��m_AiParam[1]��������ֵ�ʱ���Ƿ�ִ����Ӧ�����ĸ���
//	m_AiParam[3] ��m_AiParam[1]��������ֲ�����Ҫִ����Ӧ������ʹ�ù������ܵĸ��� ��ӦSkillList����ļ��� 1
//	m_AiParam[4��5��6] ���ֹ������ܵ�ʹ�ø��ʣ��ֱ��ӦSkillList��ļ��� 2 3 4
//	m_AiParam[7��8] �������˵��Ƚ�Զʱ��������Ѳ�ߵĸ���

void	KNpcAI::ProcessAIType03()
{
	int *pAIParam = Npc[m_nIndex].m_AiParam;
	
	// �Ƿ��ѳ�����뾶
	if (KeepActiveRange())
		return;

	int nEnemyIdx = Npc[m_nIndex].m_nPeopleIdx;
	// ���ԭ��û���������˻������������̫Զ��������������
	if (nEnemyIdx <= 0 || Npc[nEnemyIdx].m_dwID <= 0 || !InEyeshot(nEnemyIdx) )
	{
		nEnemyIdx = GetNearestNpc(relation_enemy);
		Npc[m_nIndex].m_nPeopleIdx = nEnemyIdx;
	}

	// ��Χû�е��ˣ�һ�����ʴ���/Ѳ��
	if (nEnemyIdx <= 0)
	{
		// pAIParam[0]:Ѳ�߸���
		if (pAIParam[0] > 0 && g_RandPercent(pAIParam[0]))
		{	// Ѳ��
			CommonAction();
		}
		return;
	}

	// ���ʣ�������Ƿ��������������̫��һ������ʹ�ù������ܻ�����
	if (Npc[m_nIndex].m_CurrentLife * 100 / Npc[m_nIndex].m_CurrentLifeMax < pAIParam[1])
	{
		if (g_RandPercent(pAIParam[2]))	// �Ƿ�ʹ�ù������ܻ�����
		{
			if (g_RandPercent(pAIParam[3]))	// ʹ�ù�������
			{
				Npc[m_nIndex].SetActiveSkill(1);
				FollowAttack(nEnemyIdx);
				return;
			}
			else	// ����
			{
				Flee(nEnemyIdx);
				return;
			}
		}
	}

	// ������������м��ܹ�����Χ֮�⣬һ������ѡ�����/Ѳ��/����˿���
	if (KNpcSet::GetDistanceSquare(m_nIndex, nEnemyIdx) > pAIParam[MAX_AI_PARAM - 1])
	{
		int		nRand;
		nRand = g_Random(100);
		if (nRand < pAIParam[7])	// ����
			return;
		if (nRand < pAIParam[7] + pAIParam[8])	// Ѳ��
		{
			CommonAction();
			return;
		}
		FollowAttack(nEnemyIdx);	// ����˿���
		return;
	}

	// ����������ܹ�����Χ֮�ڣ�ѡ��һ�ּ��ܹ���
	int		nRand;
	nRand = g_Random(100);
	if (nRand < pAIParam[4])
	{
		if (!Npc[m_nIndex].SetActiveSkill(2))
		{
			CommonAction();
			return;
		}
	}
	else if (nRand < pAIParam[4] + pAIParam[5])
	{
		if (!Npc[m_nIndex].SetActiveSkill(3))
		{
			CommonAction();
			return;
		}
	}
 	else if (nRand < pAIParam[4] + pAIParam[5] + pAIParam[6])
	{
		if (!Npc[m_nIndex].SetActiveSkill(4))
		{
			CommonAction();
			return;
		}
	}
	else	// ����
	{
		return;
	}
	FollowAttack(nEnemyIdx);
	//Npc[m_nIndex].m_bNpcFollowFindPath	= TRUE;
}
// Phong Than 2026-10-03 petfight: a target the attacking pet (AiMode 11) may fight: alive, visible, not a
// dialog NPC, same map, enemy of the pet and within 1000 of its owner.
static BOOL PhongThanPetTargetOk(int nPet, int nOwner, int nTarget, int nOwnX, int nOwnY)
{
	if (nTarget <= 0 || nTarget >= MAX_NPC || nTarget == nPet || nTarget == nOwner)
		return FALSE;
	KNpc &rT = Npc[nTarget];
	if (rT.m_dwID == 0 || rT.m_RegionIndex < 0 || rT.m_HideState.nTime > 0 || rT.m_Kind == kind_dialoger ||
		rT.m_CurrentLifeMax <= 0 || !rT.IsAlive() || rT.m_SubWorldIndex != Npc[nPet].m_SubWorldIndex)
		return FALSE;
	if (NpcSet.GetRelation(nPet, nTarget) != relation_enemy)
		return FALSE;
	int nX, nY;
	rT.GetMpsPos(&nX, &nY);
	return g_GetDistance(nX, nY, nOwnX, nOwnY) <= 1000;
}

#ifdef _SERVER
// Phong Than 2026-10-04 petdebug: TEMPORARY trace of the attacking-pet AI (admin_bridge\petai.log, one line per
// pet every 2 s, at most 4000 lines per server run). Remove once the pet fight bug is understood.
static int s_nPetDbgLines = 0;
static int s_nPetDbgNext[2][MAX_NPC];
void PhongThanPetDebug(int nPet, const char *pszWhere, int nOwner, int nEnemy, int nOwnerDist, const int *pCand, int nPState, int nPAI)
{
	if (s_nPetDbgLines >= 4000 || nPet <= 0 || nPet >= MAX_NPC)
		return;
	KNpc &p = Npc[nPet];
	if (p.m_SubWorldIndex < 0 || p.m_SubWorldIndex >= MAX_SUBWORLD)
		return;
	int nNow = (int)SubWorld[p.m_SubWorldIndex].m_dwCurrentTime;
	int nKind = (pszWhere && pszWhere[0] == 'a') ? 0 : 1;
	if (nNow < s_nPetDbgNext[nKind][nPet] && nNow + 100000 > s_nPetDbgNext[nKind][nPet])
		return;
	s_nPetDbgNext[nKind][nPet] = nNow + 36;
	FILE *f = fopen("admin_bridge\\petai.log", "a");
	if (!f)
		return;
	s_nPetDbgLines++;
	int nRel = (nEnemy > 0 && nEnemy < MAX_NPC) ? (int)NpcSet.GetRelation(nPet, nEnemy) : -1;
	int nDist = (nEnemy > 0 && nEnemy < MAX_NPC) ? NpcSet.GetDistance(nPet, nEnemy) : -1;
	fprintf(f, "%d %s pet=%d tpl=%d kind=%d camp=%d ai=%d doing=%d pstate=%d pai=%d owner=%d odist=%d enemy=%d rel=%d dist=%d skill=%d rad=%d s4=%d/%d s1=%d/%d",
		nNow, pszWhere, nPet, p.m_NpcSettingIdx, (int)p.m_Kind, p.m_CurrentCamp, p.m_AiMode, (int)p.m_Doing,
		nPState, nPAI, nOwner, nOwnerDist, nEnemy, nRel, nDist, p.m_ActiveSkillID,
		p.m_CurrentAttackRadius, p.m_SkillList.m_Skills[4].SkillId, p.m_SkillList.m_Skills[4].CurrentSkillLevel,
		p.m_SkillList.m_Skills[1].SkillId, p.m_SkillList.m_Skills[1].CurrentSkillLevel);
	if (pCand)
	{
		for (int c = 0; c < 7; c++)
			fprintf(f, " c%d=%d", c, pCand[c]);
	}
	fprintf(f, "\n");
	fclose(f);
}
#endif

void	KNpcAI::ProcessAIType11()
{
	if(Npc[m_nIndex].m_nOwnerIdx > 0){

		int nOwnerIdx = Npc[m_nIndex].m_nOwnerIdx;
		if ((Npc[m_nIndex].m_SubWorldIndex >= 0 && Npc[m_nIndex].m_SubWorldIndex != Npc[nOwnerIdx].m_SubWorldIndex) ||
			Npc[nOwnerIdx].m_CurrentLifeMax <= 0 || 
			Npc[nOwnerIdx].m_HideState.nTime > 0 || 
			!Npc[nOwnerIdx].IsAlive() ||
			// Phong Than 2026-10-04 dinhanbot: owner removed (KNpc::Init keeps SubWorld 0 / life 100, so a pet on
			// subworld 0 kept following an empty slot) or an NPC owner's slot reused by another NPC (name differs).
			Npc[nOwnerIdx].m_dwID == 0 ||
			(Npc[nOwnerIdx].m_Kind != kind_player && Npc[m_nIndex].Owner[0] &&
			 strcmp(Npc[m_nIndex].Owner, Npc[nOwnerIdx].Name) != 0))
			{

				// Phong Than 2026-10-03 petidx-clear: the owner must forget the removed pet, otherwise the next
				// summon skill deletes whatever NPC reuses this slot (KSkills SKILL_SS_CreateNpc).
				if (Npc[nOwnerIdx].m_nPetIdx == m_nIndex) Npc[nOwnerIdx].m_nPetIdx = 0;
				SubWorld[Npc[m_nIndex].m_SubWorldIndex].m_Region[Npc[m_nIndex].m_RegionIndex].RemoveNpc(m_nIndex);
				SubWorld[Npc[m_nIndex].m_SubWorldIndex].m_Region[Npc[m_nIndex].m_RegionIndex].DecRef(Npc[m_nIndex].m_MapX, Npc[m_nIndex].m_MapY, obj_npc);

				NpcSet.Remove(m_nIndex);
				return;	// Phong Than 2026-10-03 cppbatch:H5 the pet is gone, do not touch the freed slot
			}
		// Phong Than 2026-10-02: leash only when far away (900) or idle. The old 250 leash pulled the pet
		// back to its owner on every AI tick while it chased a target, so it never got to attack.
		int nPetX, nPetY, nOwnX, nOwnY;
		Npc[m_nIndex].GetMpsPos(&nPetX, &nPetY);
		Npc[nOwnerIdx].GetMpsPos(&nOwnX, &nOwnY);
		int nOwnerDist = g_GetDistance(nOwnX, nOwnY, nPetX, nPetY);
		if (nOwnerDist > 900) { Npc[m_nIndex].SendCommand(do_run, nOwnX, nOwnY); return; }
			// Phong Than 2026-10-03 petfight: every candidate must be a live enemy of the pet close to its owner.
			// The owner's m_nPeopleIdx is also the NPC he last talked to (dialog NPCs pass CheckNpc) and the
			// last-damage indexes may be monsters left far behind: the pet chased those (or stood still once they
			// were > 1000 away, without falling back to the nearest enemy) and never joined the fight.
			int nCand[7];
			nCand[0] = Npc[nOwnerIdx].m_SkillParam1 == -1 ? Npc[nOwnerIdx].m_SkillParam2 : 0;
			nCand[1] = Npc[nOwnerIdx].m_nLastDamageIdx;
			nCand[2] = Npc[nOwnerIdx].m_nLastPoisonDamageIdx;
			nCand[3] = Npc[nOwnerIdx].m_nPeopleIdx;
			nCand[4] = Npc[m_nIndex].m_nLastDamageIdx;
			nCand[5] = Npc[m_nIndex].m_nLastPoisonDamageIdx;
			nCand[6] = Npc[m_nIndex].m_nPeopleIdx;
			int nEnemyIdx = 0;
			for (int c = 0; c < 7 && nEnemyIdx <= 0; c++)
			{
				if (PhongThanPetTargetOk(m_nIndex, nOwnerIdx, nCand[c], nOwnX, nOwnY))
					nEnemyIdx = nCand[c];
			}
			if (nEnemyIdx <= 0)
			{
				// Phong Than 2026-10-04 petrange: pets look for monsters 800 around them (template vision is 300-400,
				// about 12 cells, so the pet ignored most of the monsters around its owner).
				int nOldVision = Npc[m_nIndex].m_VisionRadius;
				if (Npc[m_nIndex].m_VisionRadius < 800)
					Npc[m_nIndex].m_VisionRadius = 800;
				int nNear = GetNearestNpc(relation_enemy);
				Npc[m_nIndex].m_VisionRadius = nOldVision;
				if (PhongThanPetTargetOk(m_nIndex, nOwnerIdx, nNear, nOwnX, nOwnY))
					nEnemyIdx = nNear;
			}
			Npc[m_nIndex].SetActiveSkill(4);
#ifdef _SERVER
			PhongThanPetDebug(m_nIndex, "ai11", nOwnerIdx, nEnemyIdx, nOwnerDist, nCand, -1, -1);	// petdebug
#endif
			if (nEnemyIdx > 0)
				FollowAttack(nEnemyIdx);
			else if (nOwnerDist > 250)
				Npc[m_nIndex].SendCommand(do_run, nOwnX, nOwnY);
		return;
	}
}
//------------------------------------------------------------------------------
//	���ܣ���ͨ������1
//	m_AiParam[0] �޵���ʱ���Ѳ�߸���
//	m_AiParam[1��2��3��4] ���ֹ������ܵ�ʹ�ø��ʣ��ֱ��ӦSkillList��ļ��� 1 2 3 4
//	m_AiParam[5��6] �������˵��Ƚ�Զʱ��������Ѳ�ߵĸ���
//------------------------------------------------------------------------------
void	KNpcAI::ProcessAIType04()
{
	int *pAIParam = Npc[m_nIndex].m_AiParam;

	int nEnemyIdx = Npc[m_nIndex].m_nPeopleIdx;
	// �Ƿ��ܵ���������һ������ѡ�����/Ѳ��
	if (nEnemyIdx <= 0)
	{
		// pAIParam[0]:Ѳ�߸���
		if (pAIParam[0] > 0 && g_RandPercent(pAIParam[0]))
		{	// Ѳ��
			CommonAction();
		}
		return;
	}

	// �Ƿ��ѳ�����뾶
	if (KeepActiveRange())
		return;

	// ������������м��ܹ�����Χ֮�⣬һ������ѡ�����/Ѳ��/����˿���
	if (KNpcSet::GetDistanceSquare(m_nIndex, nEnemyIdx) > pAIParam[MAX_AI_PARAM - 1])
	{
		int		nRand;
		nRand = g_Random(100);
		if (nRand < pAIParam[5])	// ����
			return;
		if (nRand < pAIParam[5] + pAIParam[6])	// Ѳ��
		{
			CommonAction();
			return;
		}
		FollowAttack(nEnemyIdx);	// ����˿���
		return;
	}

	// ����������ܹ�����Χ֮�ڣ�ѡ��һ�ּ��ܹ���
	int		nRand;
	nRand = g_Random(100);
	if (nRand < pAIParam[1])
	{
		if (!Npc[m_nIndex].SetActiveSkill(1))
		{
			CommonAction();
			return;
		}
	}
	else if (nRand < pAIParam[1] + pAIParam[2])
	{
		if (!Npc[m_nIndex].SetActiveSkill(2))
		{
			CommonAction();
			return;
		}
	}
	else if (nRand < pAIParam[1] + pAIParam[2] + pAIParam[3])
	{
		if (!Npc[m_nIndex].SetActiveSkill(3))
		{
			CommonAction();
			return;
		}
	}
	else if (nRand < pAIParam[1] + pAIParam[2] + pAIParam[3] + pAIParam[4])
	{
		if (!Npc[m_nIndex].SetActiveSkill(4))
		{
			CommonAction();
			return;
		}
	}
	else	// ����
	{
		return;
	}
	FollowAttack(nEnemyIdx);
}

//------------------------------------------------------------------------------
//	���ܣ���ͨ������2
//	m_AiParam[0] �޵���ʱ���Ѳ�߸���
//	m_AiParam[1] ʣ��������������ٷֱȵ�ʱ��ִ����Ӧ����
//	m_AiParam[2] ��m_AiParam[1]��������ֵ�ʱ���Ƿ�ִ����Ӧ�����ĸ���
//	m_AiParam[3] ��m_AiParam[1]��������ֲ�����Ҫִ����Ӧ������ʹ�ûظ����ܵĸ��� ��ӦSkillList����ļ��� 1
//	m_AiParam[4��5��6] ���ֹ������ܵ�ʹ�ø��ʣ��ֱ��ӦSkillList��ļ��� 2 3 4
//	m_AiParam[7��8] �������˵��Ƚ�Զʱ��������Ѳ�ߵĸ���
//------------------------------------------------------------------------------
void	KNpcAI::ProcessAIType05()
{
	int *pAIParam = Npc[m_nIndex].m_AiParam;

	int nEnemyIdx = Npc[m_nIndex].m_nPeopleIdx;
	// �Ƿ��ܵ���������һ������ѡ�����/Ѳ��
	if (nEnemyIdx <= 0)
	{
		// pAIParam[0]:Ѳ�߸���
		if (pAIParam[0] > 0 && g_RandPercent(pAIParam[0]))
		{	// Ѳ��
			CommonAction();
		}
		return;
	}

	// �Ƿ��ѳ�����뾶
	if (KeepActiveRange())
		return;

	// ���ʣ�������Ƿ��������������̫��һ������ʹ�ò�Ѫ���ܻ�����
	if (Npc[m_nIndex].m_CurrentLife * 100 / Npc[m_nIndex].m_CurrentLifeMax < pAIParam[1])
	{
		if (g_RandPercent(pAIParam[2]))	// �Ƿ�ʹ�ò�Ѫ���ܻ�����
		{
			if (Npc[m_nIndex].m_AiAddLifeTime < pAIParam[9] && g_RandPercent(pAIParam[3]))	// ʹ�ò�Ѫ����
			{
				Npc[m_nIndex].m_AiAddLifeTime++;
				Npc[m_nIndex].SetActiveSkill(1);
				Npc[m_nIndex].SendCommand(do_skill, Npc[m_nIndex].m_ActiveSkillID, -1, m_nIndex);
				return;
			}
			else	// ����
			{
				Flee(nEnemyIdx);
				return;
			}
		}
	}

	// ������������м��ܹ�����Χ֮�⣬һ������ѡ�����/Ѳ��/����˿���
	if (KNpcSet::GetDistanceSquare(m_nIndex, nEnemyIdx) > pAIParam[MAX_AI_PARAM - 1])
	{
		int		nRand;
		nRand = g_Random(100);
		if (nRand < pAIParam[7])	// ����
			return;
		if (nRand < pAIParam[7] + pAIParam[8])	// Ѳ��
		{
			CommonAction();
			return;
		}
		FollowAttack(nEnemyIdx);	// ����˿���
		return;
	}

	// ����������ܹ�����Χ֮�ڣ�ѡ��һ�ּ��ܹ���
	int		nRand;
	nRand = g_Random(100);
	if (nRand < pAIParam[4])
	{
		if (!Npc[m_nIndex].SetActiveSkill(2))
		{
			CommonAction();
			return;
		}
	}
	else if (nRand < pAIParam[4] + pAIParam[5])
	{
		if (!Npc[m_nIndex].SetActiveSkill(3))
		{
			CommonAction();
			return;
		}
	}
	else if (nRand < pAIParam[4] + pAIParam[5] + pAIParam[6])
	{
		if (!Npc[m_nIndex].SetActiveSkill(4))
		{
			CommonAction();
			return;
		}
	}
	else	// ����
	{
		return;
	}
	FollowAttack(nEnemyIdx);
}

//------------------------------------------------------------------------------
//	���ܣ���ͨ������3
//	m_AiParam[0] �޵���ʱ���Ѳ�߸���
//	m_AiParam[1] ʣ��������������ٷֱȵ�ʱ��ִ����Ӧ����
//	m_AiParam[2] ��m_AiParam[1]��������ֵ�ʱ���Ƿ�ִ����Ӧ�����ĸ���
//	m_AiParam[3] ��m_AiParam[1]��������ֲ�����Ҫִ����Ӧ������ʹ�ù������ܵĸ��� ��ӦSkillList����ļ��� 1
//	m_AiParam[4��5��6] ���ֹ������ܵ�ʹ�ø��ʣ��ֱ��ӦSkillList��ļ��� 2 3 4
//	m_AiParam[7��8] �������˵��Ƚ�Զʱ��������Ѳ�ߵĸ���
//------------------------------------------------------------------------------
void	KNpcAI::ProcessAIType06()
{
	int *pAIParam = Npc[m_nIndex].m_AiParam;

	int nEnemyIdx = Npc[m_nIndex].m_nPeopleIdx;
	// �Ƿ��ܵ���������һ������ѡ�����/Ѳ��
	if (nEnemyIdx <= 0)
	{
		// pAIParam[0]:Ѳ�߸���
		if (pAIParam[0] > 0 && g_RandPercent(pAIParam[0]))
		{	// Ѳ��
			CommonAction();
		}
		return;
	}

	// �Ƿ��ѳ�����뾶
	if (KeepActiveRange())
		return;

	// ���ʣ�������Ƿ��������������̫��һ������ʹ�ù������ܻ�����
	if (Npc[m_nIndex].m_CurrentLife * 100 / Npc[m_nIndex].m_CurrentLifeMax < pAIParam[1])
	{
		if (g_RandPercent(pAIParam[2]))	// �Ƿ�ʹ�ù������ܻ�����
		{
			if (g_RandPercent(pAIParam[3]))	// ʹ�ù�������
			{
				Npc[m_nIndex].SetActiveSkill(1);
				FollowAttack(nEnemyIdx);	// ����˿���
				return;
			}
			else	// ����
			{
				Flee(nEnemyIdx);
				return;
			}
		}
	}

	// ������������м��ܹ�����Χ֮�⣬һ������ѡ�����/Ѳ��/����˿���
	if (KNpcSet::GetDistanceSquare(m_nIndex, nEnemyIdx) > pAIParam[MAX_AI_PARAM - 1])
	{
		int		nRand;
		nRand = g_Random(100);
		if (nRand < pAIParam[7])	// ����
			return;
		if (nRand < pAIParam[7] + pAIParam[8])	// Ѳ��
		{
			CommonAction();
			return;
		}
		FollowAttack(nEnemyIdx);	// ����˿���
		return;
	}

	// ����������ܹ�����Χ֮�ڣ�ѡ��һ�ּ��ܹ���
	int		nRand;
	nRand = g_Random(100);
	if (nRand < pAIParam[4])
	{
		if (!Npc[m_nIndex].SetActiveSkill(2))
		{
			CommonAction();
			return;
		}
	}
	else if (nRand < pAIParam[4] + pAIParam[5])
	{
		if (!Npc[m_nIndex].SetActiveSkill(3))
		{
			CommonAction();
			return;
		}
	}
	else if (nRand < pAIParam[4] + pAIParam[5] + pAIParam[6])
	{
		if (!Npc[m_nIndex].SetActiveSkill(4))
		{
			CommonAction();
			return;
		}
	}
	else	// ����
	{
		return;
	}
	FollowAttack(nEnemyIdx);
}

/*
// һ��������
void KNpcAI::ProcessAIType1()
{
	int *pAIParam = Npc[m_nIndex].m_AiParam;
	// �Ƿ��ѳ�����뾶
	if (KeepActiveRange())
		return;

	if (Npc[m_nIndex].m_CurrentLife * 100 / Npc[m_nIndex].m_CurrentLifeMax < pAIParam[0])
	{
		if (g_RandPercent(pAIParam[1]))
		{
			Npc[m_nIndex].SetActiveSkill(1);
			Npc[m_nIndex].SendCommand(do_skill, Npc[m_nIndex].m_ActiveSkillID, -1, m_nIndex);
			return;
		}
	}

	int nEnemyIdx = Npc[m_nIndex].m_nPeopleIdx;
	
	if (nEnemyIdx <= 0 || Npc[nEnemyIdx].m_dwID <= 0 || !InEyeshot(nEnemyIdx) )
	{
		nEnemyIdx = GetNearestNpc(relation_enemy);
		Npc[m_nIndex].m_nPeopleIdx = nEnemyIdx;
	}
	
	

	if (nEnemyIdx > 0)
	{
		int		nRand;
		nRand = g_Random(100);
		if (nRand < pAIParam[2])
		{
			if (!Npc[m_nIndex].SetActiveSkill(2))
			{
				CommonAction();
				return;
			}
		}
		else if (nRand < pAIParam[2] + pAIParam[3])
		{
			if (!Npc[m_nIndex].SetActiveSkill(3))
			{
				CommonAction();
				return;
			}
		}
		else if (nRand < pAIParam[2] + pAIParam[3] + pAIParam[4])
		{
			if (!Npc[m_nIndex].SetActiveSkill(4))
			{
				CommonAction();
				return;
			}
		}

//		if (g_RandPercent(pAIParam[2]))
//		{
//			Npc[m_nIndex].SetActiveSkill(2);
//		}
//		else if (g_RandPercent(pAIParam[3]))
//		{
//			Npc[m_nIndex].SetActiveSkill(3);
//		}
//		else if (g_RandPercent(pAIParam[4]))
//		{
//			Npc[m_nIndex].SetActiveSkill(4);
//		}
		else
		{
			CommonAction();
			return;
		}
		FollowAttack(nEnemyIdx);
		return;
	}
	CommonAction();
}
*/

/*
// һ�㱻����
void KNpcAI::ProcessAIType2()
{
	int *pAIParam = Npc[m_nIndex].m_AiParam;

	if (KeepActiveRange())
		return;

	if (Npc[m_nIndex].m_CurrentLife * 100 / Npc[m_nIndex].m_CurrentLifeMax < pAIParam[0])
	{
		if (g_RandPercent(pAIParam[1]))
		{
			Npc[m_nIndex].SetActiveSkill(1);
			Npc[m_nIndex].SendCommand(do_skill, Npc[m_nIndex].m_ActiveSkillID, -1, m_nIndex);
			return;
		}
	}

	int nEnemyIdx = Npc[m_nIndex].m_nPeopleIdx;
	if (nEnemyIdx <= 0 || !InEyeshot(nEnemyIdx))
		return;

	int		nRand;
	nRand = g_Random(100);

	if (nRand < pAIParam[2])
	{
		if (!Npc[m_nIndex].SetActiveSkill(2))
		{
			CommonAction();
			return;
		}
	}
	else if (nRand < pAIParam[2] + pAIParam[3])
	{
		if (!Npc[m_nIndex].SetActiveSkill(3))
		{
			CommonAction();
			return;
		}
	}
	else if (nRand < pAIParam[2] + pAIParam[3] + pAIParam[4])
	{
		if (!Npc[m_nIndex].SetActiveSkill(4))
		{
			CommonAction();
			return;
		}
	}

//	if (g_RandPercent(pAIParam[2]))
//	{
//		Npc[m_nIndex].SetActiveSkill(2);
//	}
//	else if (g_RandPercent(pAIParam[3]))
//	{
//		Npc[m_nIndex].SetActiveSkill(3);
//	}
//	else if (g_RandPercent(pAIParam[4]))
//	{
//		Npc[m_nIndex].SetActiveSkill(4);
//	}
	else
	{
		CommonAction();
		return;
	}
	FollowAttack(nEnemyIdx);

	return;
}
*/

/*
// һ��������
void KNpcAI::ProcessAIType3()
{
	int* pAIParam = Npc[m_nIndex].m_AiParam;

	if (KeepActiveRange())
		return;

	int	nEnemyIdx = Npc[m_nIndex].m_nPeopleIdx;

	if (nEnemyIdx <= 0 || !InEyeshot(nEnemyIdx))
	{
		nEnemyIdx = GetNearestNpc(relation_enemy);
		Npc[m_nIndex].m_nPeopleIdx = nEnemyIdx;
	}

	if (nEnemyIdx <= 0)
	{
		CommonAction();
		return;
	}
	
	if (Npc[m_nIndex].m_CurrentLife * 100 / Npc[m_nIndex].m_CurrentLifeMax < pAIParam[0])
	{
		if (g_RandPercent(pAIParam[1]))
		{
			Flee(nEnemyIdx);
			return;
		}
	}

	int		nRand;
	nRand = g_Random(100);

	if (nRand < pAIParam[2])
	{
		if (!Npc[m_nIndex].SetActiveSkill(1))
		{
			CommonAction();
			return;
		}
	}
	else if (nRand < pAIParam[2] + pAIParam[3])
	{
		if (!Npc[m_nIndex].SetActiveSkill(2))
		{
			CommonAction();
			return;
		}
	}
	else if (nRand < pAIParam[2] + pAIParam[3] + pAIParam[4])
	{
		if (!Npc[m_nIndex].SetActiveSkill(3))
		{
			CommonAction();
			return;
		}
	}

//	if (g_RandPercent(pAIParam[2]))
///	{
//		Npc[m_nIndex].SetActiveSkill(1);
//	}
//	else if (g_RandPercent(pAIParam[3]))
//	{
//		Npc[m_nIndex].SetActiveSkill(2);
//	}
//	else if (g_RandPercent(pAIParam[4]))
//	{
//		Npc[m_nIndex].SetActiveSkill(3);
//	}
	else
	{
		CommonAction();
		return;
	}
	FollowAttack(nEnemyIdx);
	return;
}
*/

/*
// ���ܼ�ǿ��
void KNpcAI::ProcessAIType4()
{
	int*	pAIParam = Npc[m_nIndex].m_AiParam;
	
	if (KeepActiveRange())
		return;

	int	nEnemyIdx = Npc[m_nIndex].m_nPeopleIdx;

	if (nEnemyIdx <= 0 || !InEyeshot(nEnemyIdx))
	{
		nEnemyIdx = GetNearestNpc(relation_enemy);
		Npc[m_nIndex].m_nPeopleIdx = nEnemyIdx;
	}

	if (nEnemyIdx <= 0)
	{
		CommonAction();
		return;
	}
	
	int nLifePercent = Npc[m_nIndex].m_CurrentLife * 100 / Npc[m_nIndex].m_CurrentLifeMax;
	if (nLifePercent < pAIParam[0])
	{
		if (g_RandPercent(pAIParam[1]))
		{
			Flee(nEnemyIdx);
			return;
		}
	}
	if (nLifePercent < pAIParam[2])
	{
		if (g_RandPercent(pAIParam[3]))
		{
			Npc[m_nIndex].SetActiveSkill(1);
			Npc[m_nIndex].SendCommand(do_skill, Npc[m_nIndex].m_ActiveSkillID, -1, m_nIndex);
			return;
		}
	}

	if (g_RandPercent(pAIParam[4]))
	{
		Npc[m_nIndex].SetActiveSkill(2);
	}
	else if (g_RandPercent(pAIParam[5]))
	{
		Npc[m_nIndex].SetActiveSkill(3);
	}
	else
	{
		CommonAction();
		return;
	}
	FollowAttack(nEnemyIdx);
	return;
}
*/

/*
//	�˶������
void KNpcAI::ProcessAIType5()
{
	int *pAIParam = Npc[m_nIndex].m_AiParam;

	if (KeepActiveRange())
		return;

	int i = Npc[m_nIndex].m_nPeopleIdx;

	if (!i || !InEyeshot(i))
	{
		i = GetNearestNpc(relation_enemy);
		Npc[m_nIndex].m_nPeopleIdx = i;
	}

	if (!i)
	{
		CommonAction();
		return;
	}

	int nEnemyNumber = GetNpcNumber(relation_enemy);
	if (nEnemyNumber > pAIParam[0])
	{
		if (g_RandPercent(pAIParam[1]))
		{
			Flee(i);
			return;
		}
	}

	if (g_RandPercent(pAIParam[2]))
	{
		Npc[m_nIndex].SetActiveSkill(1);
	}
	else if (nEnemyNumber <= pAIParam[3] && g_RandPercent(pAIParam[4]))
	{
		Npc[m_nIndex].SetActiveSkill(2);
	}
	else
	{
		CommonAction();
		return;
	}

	FollowAttack(i);
	return;
}
*/

/*
//	��Ⱥ�����
void KNpcAI::ProcessAIType6()
{
	int *pAIParam = Npc[m_nIndex].m_AiParam;

	if (KeepActiveRange())
		return;

	int i = Npc[m_nIndex].m_nPeopleIdx;
	if (!i || !InEyeshot(i))
	{
		i = GetNearestNpc(relation_enemy);
		Npc[m_nIndex].m_nPeopleIdx = i;
	}

	if (!i)
	{
		CommonAction();
		return;
	}

	int nAllyNumber = GetNpcNumber(relation_none);
	if (nAllyNumber <= pAIParam[0])
	{
		if (g_RandPercent(pAIParam[1]))
		{
			Flee(i);
			return;
		}
	}
	
	if (g_RandPercent(pAIParam[2]))
	{
		Npc[m_nIndex].SetActiveSkill(1);
	}
	else if (nAllyNumber > pAIParam[3] && g_RandPercent(pAIParam[4]))
	{
		Npc[m_nIndex].SetActiveSkill(2);
	}
	else
	{
		CommonAction();
		return;
	}

	FollowAttack(i);
	return;
}
*/

/*
// ����۶���
void KNpcAI::ProcessAIType7()
{
	int *pAIParam = Npc[m_nIndex].m_AiParam;

	if (KeepActiveRange())
		return;

	int i = Npc[m_nIndex].m_nPeopleIdx;
	if (!i || !InEyeshot(i))
	{
		i = GetNearestNpc(relation_enemy);
		Npc[m_nIndex].m_nPeopleIdx = i;
	}

	if (!i)
	{
		CommonAction();
		return;
	}

	int j = GetNearestNpc(relation_ally);

	if (j && Npc[m_nIndex].m_CurrentLife * 100 / Npc[m_nIndex].m_CurrentLifeMax < pAIParam[0])
	{
		if (g_RandPercent(pAIParam[1]))
		{
			int x, y;
			Npc[j].GetMpsPos(&x, &y);
			Npc[m_nIndex].SendCommand(do_walk, x, y);
			return;
		}
	}

	if (g_RandPercent(pAIParam[2]))
	{
		Npc[m_nIndex].SetActiveSkill(1);
	}
	else if (g_RandPercent(pAIParam[3]))
	{
		Npc[m_nIndex].SetActiveSkill(2);
	}
	else if (g_RandPercent(pAIParam[4]))
	{
		Npc[m_nIndex].SetActiveSkill(3);
	}
	else
	{
		CommonAction();
		return;
	}
	FollowAttack(i);
	return;
}
*/

/*
//	����������
void KNpcAI::ProcessAIType8()
{
	int *pAIParam = Npc[m_nIndex].m_AiParam;

	if (KeepActiveRange())
		return;

	int i = Npc[m_nIndex].m_nPeopleIdx;

	if (!i || !InEyeshot(i))
	{
		i = GetNearestNpc(relation_enemy);
		Npc[m_nIndex].m_nPeopleIdx = i;
	}

	if (!i)
	{
		CommonAction();
		return;
	}
	
	if (g_RandPercent(pAIParam[0]))
	{
		int x, y;

		Npc[i].GetMpsPos(&x, &y);
		Npc[m_nIndex].SendCommand(do_walk, x, y);
	}
	else if (g_RandPercent(pAIParam[1]))
	{
		Npc[m_nIndex].SetActiveSkill(1);
	}
	else if (g_RandPercent(pAIParam[2]))
	{
		Npc[m_nIndex].SetActiveSkill(2);
	}
	else if (g_RandPercent(pAIParam[3]))
	{
		Npc[m_nIndex].SetActiveSkill(3);
	}
	else
	{
		CommonAction();
		return;
	}
	FollowAttack(i);
	return;
}
*/

/*
//	ԽսԽ����
void KNpcAI::ProcessAIType9()
{
	int *pAIParam = Npc[m_nIndex].m_AiParam;

	if (KeepActiveRange())
		return;

	int i = Npc[m_nIndex].m_nPeopleIdx;

	if (!i || !InEyeshot(i))
	{
		i = GetNearestNpc(relation_enemy);
		Npc[m_nIndex].m_nPeopleIdx = i;
	}

	if (!i)
	{
		CommonAction();
		return;
	}
	
	int nLifePercent = Npc[m_nIndex].m_CurrentLife * 100 / Npc[m_nIndex].m_CurrentLifeMax;

	if (g_RandPercent(pAIParam[0]))
	{
		Npc[m_nIndex].SetActiveSkill(1);
	}
	else if (nLifePercent < pAIParam[1] && g_RandPercent(pAIParam[2]))
	{
		Npc[m_nIndex].SetActiveSkill(2);
	}
	else if (nLifePercent < pAIParam[3] && g_RandPercent(pAIParam[4]))
	{
		Npc[m_nIndex].SetActiveSkill(3);
	}
	else
	{
		CommonAction();
		return;
	}
	FollowAttack(i);
	return;
}
*/

/*
//	���ܲ�����
void KNpcAI::ProcessAIType10()
{
	int *pAIParam = Npc[m_nIndex].m_AiParam;

	if (KeepActiveRange())
		return;

	int i = Npc[m_nIndex].m_nPeopleIdx;

	if (!i || !InEyeshot(i))
	{
		i = GetNearestNpc(relation_enemy);
		Npc[m_nIndex].m_nPeopleIdx = i;
	}

	if (!i)
	{
		CommonAction();
		return;
	}
	
	int nLifePercent = Npc[m_nIndex].m_CurrentLife * 100 / Npc[m_nIndex].m_CurrentLifeMax;

	if (nLifePercent < pAIParam[0] && g_RandPercent(pAIParam[1]))
	{
		Npc[m_nIndex].SetActiveSkill(1);
	}
	else if (nLifePercent < pAIParam[2] && g_RandPercent(pAIParam[3]))
	{
		Npc[m_nIndex].SetActiveSkill(2);
	}
	else if (nLifePercent < pAIParam[4] && g_RandPercent(pAIParam[5]))
	{
		Flee(i);
		return;
	}
	else
	{
		CommonAction();
		return;
	}

	FollowAttack(i);
	return;
}
*/
