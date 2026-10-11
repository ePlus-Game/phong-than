// Phong Than 2026-10-03 autofight: client auto fight ("tu dong danh"), like VNG's auto play.
//
// Included ONCE, at the end of KPlayerAI.cpp, client build only. ASCII only; the player-visible strings
// are TCVN3 bytes written as escapes.
//
// Toggle: VNG's \Ui\autoexec.lua already binds Alt+A Switch([[leftautoai]]), Alt+S Switch([[rightautoai]])
// and Alt+D Switch([[rightlocalautoai]]). ShortcutKey.cpp (LuaSwitchStatus) maps them to
// KCoreShell::PAIOperation(PTAF_GPI_AUTOFIGHT, mode) -> PTAutoFight_Operation(mode).
//   mode 1 = left skill, mode 2 = right skill (falls back to the left skill), mode 3 = right skill, stay put.
// Pressing the same key again turns it off; another auto key switches the mode.
//
// Tick: KPlayerAI::Active() (called from KPlayer::Active() every client frame) -> PTAutoFight_Tick().
// Manual input: KPlayer::ProcessMouse() (a click or drag in the game world) -> PTAutoFight_OnManualInput().
//
// Every action uses the same client calls a mouse click uses (Npc.SendCommand + SendClientCmdSkill /
// SendClientCmdRun / SendClientCmdWalk, Player.ApplyUseItem for a quick-bar potion), with the same
// CanCast/Cost checks as KPlayer::ProcessMouse. The server validates them exactly as it validates clicks:
// nothing is added to the protocol and nothing changes server-side.
#ifndef _SERVER
#ifndef PHONGTHAN_AUTOFIGHT_INL
#define PHONGTHAN_AUTOFIGHT_INL

#define PTAF_GPI_AUTOFIGHT      0x50544146  // 'PTAF', private PAIOperation code (also used in ShortcutKey.cpp)
#define PTAF_QUERY              0xFF        // PAIOperation(PTAF_GPI_AUTOFIGHT, PTAF_QUERY) returns the mode
#define PTAF_SEARCH_RADIUS      640         // look for monsters this far from the player
#define PTAF_LEASH_RADIUS       960         // never take a target farther than this from the start spot
#define PTAF_STAY_EXTRA         32          // mode 3: skill range + this around the start spot
#define PTAF_HOME_SLACK         48          // close enough to the start spot
#define PTAF_THINK_MS           100         // decide at most 10 times a second
#define PTAF_SKILL_GAP_MS       200         // never send two skill requests closer than this
#define PTAF_MOVE_GAP_MS        400         // never send two move requests closer than this
#define PTAF_CHASE_GIVEUP_MS    6000        // cannot reach a target for this long -> skip it
#define PTAF_NOHIT_GIVEUP_MS    15000       // target life unchanged for this long -> skip it
#define PTAF_IGNORE_MS          20000       // how long a skipped target stays skipped
#define PTAF_PAUSE_MS           4000        // a manual click pauses auto this long
#define PTAF_POTION_GAP_MS      2500        // one potion of each kind at most every 2.5 s
#define PTAF_HP_PERCENT         50          // drink a red/both potion below 50% life
#define PTAF_MP_PERCENT         20          // drink a blue/both potion below 20% mana
#define PTAF_IGNORE_SLOTS       8
#define PTAF_BOT_TPL_MIN        2703        // fake player bots (docs\features\bot-gia-nguoi-choi-phong-than-20261002.md)
#define PTAF_BOT_TPL_MAX        2720

// Phong Than 2026-10-04 daosi: skill rotation (docs\features\dao-si-nhieu-chieu-phong-than-20261004.md).
// Alt+R (ShortcutKey.cpp fallback, any time) toggles it; on by default. The UI pushes the skills of the
// nine VNG quick keys (Q W E / A S D / Z X C, KUiSkillTree) with PTAF_OP_LIST_* before each start and
// whenever a quick key is (re)assigned.
#include "KPhongThanProfessionSkills.h"
#define PTAF_OP_ROTATE          0x10        // toggle rotation, returns the new state (0/1)
#define PTAF_OP_LIST_CLEAR      0x11        // UI: forget the quick-key skill list
#define PTAF_OP_LIST_ADD        0x12        // UI: add a quick-key skill, nParam = skill id
#define PTAF_OP_ROTATE_QUERY    0x13        // returns the rotation state
#define PTAF_LIST_MAX           24

// TCVN3 strings (generated from Unicode with the tcvn() table of S\ptfix\build_ptfix.py).
#define PTAF_S_ON       "T\xf9 \xae\xe9ng \xae\xb8nh: B\xcbT"                                   // Tu dong danh: BAT
#define PTAF_S_OFF      "T\xf9 \xae\xe9ng \xae\xb8nh: T\xbeT"                                   // Tu dong danh: TAT
#define PTAF_S_M1       " (chi\xaau tay tr\xb8i)"                                               // (chieu tay trai)
#define PTAF_S_M2       " (chi\xaau tay ph\xb6i)"                                               // (chieu tay phai)
#define PTAF_S_M3       " (\xae\xf8ng t\xb9i ch\xe7)"                                           // (dung tai cho)
#define PTAF_S_R_SAFE   " - \xae""ang \xeb khu v\xf9""c an to\xb5n"                             // - dang o khu vuc an toan
#define PTAF_S_R_MAP    " - \xae\xb7 \xae\xe6i b\xb6n \xae\xe5"                                 // - da doi ban do
#define PTAF_S_R_DEATH  " - nh\xa9n v\xcbt b\xde tr\xe4ng th\xad\xacng"                         // - nhan vat bi trong thuong
#define PTAF_S_R_DIALOG " - \xae""ang m\xeb h\xe9i tho\xb9i"                                    // - dang mo hoi thoai
#define PTAF_S_R_TRADE  " - \xae""ang giao d\xde""ch"                                           // - dang giao dich
#define PTAF_S_NOSAFE   "Kh\xabng th\xd3 t\xf9 \xae\xe9ng \xae\xb8nh trong khu v\xf9""c an to\xb5n."   // Khong the ... an toan.
#define PTAF_S_PAUSE    "T\xf9 \xae\xe9ng \xae\xb8nh t\xb9m d\xf5ng, s\xcf ti\xd5p t\xf4""c t\xb9i v\xde tr\xdd m\xedi."  // tam dung ...
#define PTAF_S_ROT_ON   "Lu\xa9n phi\xaan chi\xaau khi t\xf9 \xae\xb8nh: B\xcbT"                                      // Luan phien chieu khi tu danh: BAT
#define PTAF_S_ROT_OFF  "Lu\xa9n phi\xaan chi\xaau khi t\xf9 \xae\xb8nh: T\xbeT (ch\xd8 d\xefng 1 chi\xaau)"          // ...: TAT (chi dung 1 chieu)
#define PTAF_S_ROT_N    " - lu\xa9n phi\xaan %d chi\xaau (Alt+R b\xcbt/t\xbet)"                                      // - luan phien %d chieu (Alt+R bat/tat)
#define PTAF_S_ROT_ONE  " - 1 chi\xaau (Alt+R: lu\xa9n phi\xaan)"                                                  // - 1 chieu (Alt+R: luan phien)

static int              s_nPTAFMode = 0;            // 0 off, 1 left skill, 2 right skill, 3 right skill stay put
static int              s_nPTAFHomeX = 0;           // start spot (Mps)
static int              s_nPTAFHomeY = 0;
static int              s_nPTAFWorldID = 0;         // SubWorld[0].m_SubWorldID when started
static unsigned int     s_uPTAFDialogToken = 0;     // last seen Player.m_UiDialogToken
static int              s_nPTAFTarget = 0;          // Npc index
static DWORD            s_dwPTAFTargetID = 0;       // its m_dwID (index reuse guard)
static int              s_nPTAFTargetLife = 0;
static DWORD            s_uPTAFLifeAt = 0;
static DWORD            s_uPTAFChaseSince = 0;
static DWORD            s_uPTAFLastThink = 0;
static DWORD            s_uPTAFLastSkill = 0;
static DWORD            s_uPTAFLastMove = 0;
static int              s_nPTAFLastDestX = 0;
static int              s_nPTAFLastDestY = 0;
static BOOL             s_bPTAFPaused = FALSE;
static DWORD            s_uPTAFPauseUntil = 0;
static DWORD            s_uPTAFLastHp = 0;
static DWORD            s_uPTAFLastMp = 0;
static DWORD            s_dwPTAFIgnoreID[PTAF_IGNORE_SLOTS];
static DWORD            s_uPTAFIgnoreUntil[PTAF_IGNORE_SLOTS];
static BOOL             s_bPTAFRotate = TRUE;       // daosi: rotate between several attack skills
static int              s_aPTAFUiSkill[PTAF_LIST_MAX];  // daosi: skills of the quick keys (pushed by the UI)
static int              s_nPTAFUiSkill = 0;
static int              s_aPTAFUsedID[PTAF_LIST_MAX];   // daosi: when each skill was last sent by the auto
static DWORD            s_uPTAFUsedAt[PTAF_LIST_MAX];

static void PTAF_Say(const char* a, const char* b, BOOL bTop)
{
	KSystemMessage sMsg;
	memset(&sMsg, 0, sizeof(sMsg));
	_snprintf(sMsg.szMessage, sizeof(sMsg.szMessage) - 1, "%s%s", a ? a : "", b ? b : "");
	sMsg.szMessage[sizeof(sMsg.szMessage) - 1] = 0;
	sMsg.eType = SMT_NORMAL;
	sMsg.byConfirmType = SMCT_NONE;
	sMsg.byPriority = 0;
	sMsg.byParamSize = 0;
	CoreDataChanged(GDCNI_SYSTEM_MESSAGE, (unsigned int)&sMsg, 0);
	if (bTop)
		CoreDataChanged(GDCNI_TOP_MESSAGE, (unsigned int)sMsg.szMessage, (int)strlen(sMsg.szMessage));
}

static int PTAF_Me()
{
	int n = Player[CLIENT_PLAYER_INDEX].m_nIndex;
	return (n > 0 && n < MAX_NPC) ? n : 0;
}

// Squared distance in double: Mps coordinates of big maps overflow a 32-bit square.
static double PTAF_D2(int x1, int y1, int x2, int y2)
{
	double dx = (double)(x1 - x2);
	double dy = (double)(y1 - y2);
	return dx * dx + dy * dy;
}

static BOOL PTAF_IsIgnored(DWORD dwID, DWORD uNow)
{
	for (int i = 0; i < PTAF_IGNORE_SLOTS; i++)
	{
		if (s_dwPTAFIgnoreID[i] == dwID && dwID && (int)(s_uPTAFIgnoreUntil[i] - uNow) > 0)
			return TRUE;
	}
	return FALSE;
}

static void PTAF_Ignore(DWORD dwID, DWORD uNow)
{
	int nSlot = 0;
	for (int i = 0; i < PTAF_IGNORE_SLOTS; i++)
	{
		if (!s_dwPTAFIgnoreID[i] || (int)(s_uPTAFIgnoreUntil[i] - uNow) <= 0)
		{
			nSlot = i;
			break;
		}
		if ((int)(s_uPTAFIgnoreUntil[i] - s_uPTAFIgnoreUntil[nSlot]) < 0)
			nSlot = i;
	}
	s_dwPTAFIgnoreID[nSlot] = dwID;
	s_uPTAFIgnoreUntil[nSlot] = uNow + PTAF_IGNORE_MS;
}

static void PTAF_DropTarget()
{
	s_nPTAFTarget = 0;
	s_dwPTAFTargetID = 0;
	s_uPTAFChaseSince = 0;
}

// The skill the current mode prefers (right skill in modes 2 and 3, left skill in mode 1).
static int PTAF_PreferredSkill()
{
	return s_nPTAFMode == 1 ? Player[CLIENT_PLAYER_INDEX].GetLeftSkill() : Player[CLIENT_PLAYER_INDEX].GetRightSkill();
}

// Attack range of the preferred skill at its current level (mode 3 area), at least 64.
static int PTAF_PreferredRadius(int nMe)
{
	int nRadius = 0;
	int nSkill = PTAF_PreferredSkill();
	if (nSkill > 0 && Npc[nMe].m_SkillList.FindSame(nSkill) > 0)
	{
		int nLevel = Npc[nMe].m_SkillList.GetCurrentLevel(nSkill);
		ISkill* pSkill = g_SkillManager.GetSkill(nSkill, nLevel > 0 ? nLevel : 1);
		if (pSkill)
			nRadius = pSkill->GetAttackRadius();
	}
	if (nRadius < 64)
		nRadius = 64;
	return nRadius;
}

// Monster the auto may attack: a server NPC of kind "normal" (not a player, not a dialog NPC), alive,
// visible, hostile to us, not a fake player bot, not an owned pet, not skipped.
static BOOL PTAF_IsCandidate(int nMe, int i, DWORD uNow)
{
	if (i <= 0 || i >= MAX_NPC || i == nMe)
		return FALSE;
	KNpc& t = Npc[i];
	if (t.m_Index <= 0 || t.m_dwID == 0)
		return FALSE;
	if (t.m_Kind != kind_normal || t.m_bClientOnly)
		return FALSE;
	if (t.m_RegionIndex < 0 || t.m_SubWorldIndex != Npc[nMe].m_SubWorldIndex)
		return FALSE;
	if (!t.IsAlive() || t.m_CurrentLifeMax <= 0 || t.m_HideState.nTime > 0)
		return FALSE;
	if (t.m_NpcSettingIdx >= PTAF_BOT_TPL_MIN && t.m_NpcSettingIdx <= PTAF_BOT_TPL_MAX)
		return FALSE;
	if (t.m_nOwnerIdx > 0)
		return FALSE;
	if (NpcSet.GetRelation(nMe, i) != relation_enemy)
		return FALSE;
	if (PTAF_IsIgnored(t.m_dwID, uNow))
		return FALSE;
	return TRUE;
}

// Inside the allowed area around the start spot.
static BOOL PTAF_InArea(int nMe, int i)
{
	int x, y;
	Npc[i].GetMpsPos(&x, &y);
	double r = (double)(s_nPTAFMode == 3 ? PTAF_PreferredRadius(nMe) + PTAF_STAY_EXTRA : PTAF_LEASH_RADIUS);
	return PTAF_D2(x, y, s_nPTAFHomeX, s_nPTAFHomeY) <= r * r;
}

static int PTAF_FindTarget(int nMe, DWORD uNow)
{
	int mx, my;
	Npc[nMe].GetMpsPos(&mx, &my);
	const double rMe = (double)PTAF_SEARCH_RADIUS * PTAF_SEARCH_RADIUS;
	int nBest = 0;
	double dBest = 0;
	int nGuard = 0;
	for (int i = NpcSet.GetNextIdx(0); i > 0 && nGuard < MAX_NPC; i = NpcSet.GetNextIdx(i), nGuard++)
	{
		if (!PTAF_IsCandidate(nMe, i, uNow))
			continue;
		int x, y;
		Npc[i].GetMpsPos(&x, &y);
		double d = PTAF_D2(mx, my, x, y);
		if (d > rMe || !PTAF_InArea(nMe, i))
			continue;
		if (!nBest || d < dBest)
		{
			nBest = i;
			dBest = d;
		}
	}
	return nBest;
}

// Same gate as a mouse click: the player NPC accepts input and is not in the middle of an action.
static BOOL PTAF_Ready(int nMe)
{
	KNpc& me = Npc[nMe];
	if (!me.IsCanInput())
		return FALSE;
	switch (me.m_Doing)
	{
	case do_none:
	case do_stand:
	case do_walk:
	case do_run:
	case do_sit:
	case do_idle:
		return TRUE;
	default:
		return FALSE;
	}
}

// An attack skill the auto may cast, the same filter a mouse click implies (KPlayer::ProcessMouse): learnt,
// not an aura or a passive, aimed at enemies (on the NPC) or at a position (not ally/self/object/target-only).
static BOOL PTAF_IsAttackSkill(KNpc& me, int nSkill, BOOL* pbOnTarget)
{
	if (nSkill <= 0 || nSkill >= MAX_SKILL)
		return FALSE;
	if (me.m_SkillList.FindSame(nSkill) <= 0 || me.m_SkillList.GetCurrentLevel(nSkill) <= 0)
		return FALSE;
	ISkill* pSkill = g_SkillManager.GetSkill(nSkill, 1);
	if (!pSkill || pSkill->IsAura() || pSkill->GetSkillStyle() == SKILL_SS_PassivityNpcState)
		return FALSE;
	if (pSkill->IsTargetEnemy())
	{
		*pbOnTarget = TRUE;
		return TRUE;
	}
	if (pSkill->IsTargetAlly() || pSkill->IsTargetObj() || pSkill->IsTargetOnly() || pSkill->IsTargetSelf())
		return FALSE;
	*pbOnTarget = FALSE;
	return TRUE;
}

static void PTAF_AddUnique(int* a, int* pn, int nSkill)
{
	if (nSkill <= 0 || *pn >= PTAF_LIST_MAX)
		return;
	for (int i = 0; i < *pn; i++)
	{
		if (a[i] == nSkill)
			return;
	}
	a[(*pn)++] = nSkill;
}

// daosi: the skills the auto may use.
//   Rotation off: the preferred skill, then (modes 2/3) the left skill, exactly as before 2026-10-04.
//   Rotation on : preferred, left, right and the quick-key skills, attack skills only, without the plain
//                 weapon attack when real skills exist. Fewer than 2: every learnt attack skill of the
//                 profession (Dao Si 3..26 of all elements, Giap Si 27..42, Di Nhan 43..51).
static int PTAF_SkillList(KNpc& me, int* a)
{
	KPlayer& pl = Player[CLIENT_PLAYER_INDEX];
	int n = 0;
	PTAF_AddUnique(a, &n, PTAF_PreferredSkill());
	if (s_nPTAFMode != 1 || s_bPTAFRotate)
		PTAF_AddUnique(a, &n, pl.GetLeftSkill());
	if (!s_bPTAFRotate)
		return n;
	PTAF_AddUnique(a, &n, pl.GetRightSkill());
	int i;
	for (i = 0; i < s_nPTAFUiSkill; i++)
		PTAF_AddUnique(a, &n, s_aPTAFUiSkill[i]);
	BOOL bOnTarget;
	int k = 0;
	for (i = 0; i < n; i++)
	{
		if (PTAF_IsAttackSkill(me, a[i], &bOnTarget))
			a[k++] = a[i];
	}
	n = k;
	if (n < 2)
	{
		for (i = 1; i < MAX_NPCSKILL && n < PTAF_LIST_MAX; i++)
		{
			int nId = me.m_SkillList.m_Skills[i].SkillId;
			if (PhongThanIsProfessionSkill(nId) && PTAF_IsAttackSkill(me, nId, &bOnTarget))
				PTAF_AddUnique(a, &n, nId);
		}
	}
	if (n > 2)
	{
		int nWeapon = me.GetCurActiveWeaponSkill();
		k = 0;
		for (i = 0; i < n; i++)
		{
			if (a[i] != nWeapon)
				a[k++] = a[i];
		}
		n = k;
	}
	return n;
}

static DWORD PTAF_LastUsed(int nSkill)
{
	for (int i = 0; i < PTAF_LIST_MAX; i++)
	{
		if (s_aPTAFUsedID[i] == nSkill)
			return s_uPTAFUsedAt[i];
	}
	return 0;
}

static void PTAF_MarkUsed(int nSkill, DWORD uNow)
{
	int nSlot = 0;
	for (int i = 0; i < PTAF_LIST_MAX; i++)
	{
		if (s_aPTAFUsedID[i] == nSkill)
		{
			nSlot = i;
			break;
		}
		if ((int)(s_uPTAFUsedAt[i] - s_uPTAFUsedAt[nSlot]) < 0)
			nSlot = i;
	}
	s_aPTAFUsedID[nSlot] = nSkill;
	s_uPTAFUsedAt[nSlot] = uNow ? uNow : 1;
}

// Picks the skill with the same checks as a click on the monster: off cooldown (CanCast, the per-skill
// TimePerCast of skills.txt) and affordable (Cost audit, no message).
//   Rotation off: the first usable skill of the list (old behaviour).
//   Rotation on : a skill that reaches the target first; among those the skills that have a TimePerCast
//                 (the big skills of each element: Dao Si 23 = 125 frames, 18/26 = 40, 25 = 20) whenever
//                 one is ready, taking turns (the one sent longest ago first, so every element gets its
//                 turn); the no-cooldown skills fill the gaps, also taking turns. If none reaches the
//                 target, the longest reach (the auto then closes in).
static int PTAF_PickSkill(int nMe, int nDist, int* pnRadius, BOOL* pbOnTarget)
{
	KNpc& me = Npc[nMe];
	int aSkill[PTAF_LIST_MAX];
	int nCount = PTAF_SkillList(me, aSkill);
	DWORD dwNow = SubWorld[me.m_SubWorldIndex].m_dwCurrentTime;
	int nBest = 0;
	int nBestRadius = 0;
	int nBestWait = 0;
	BOOL bBestIn = FALSE;
	BOOL bBestOnTarget = TRUE;
	DWORD uBestUsed = 0;
	for (int k = 0; k < nCount; k++)
	{
		int nSkill = aSkill[k];
		BOOL bOnTarget = TRUE;
		if (!PTAF_IsAttackSkill(me, nSkill, &bOnTarget))
			continue;
		int nLevel = me.m_SkillList.GetCurrentLevel(nSkill);
		ISkill* pSkill = g_SkillManager.GetSkill(nSkill, nLevel > 0 ? nLevel : 1);
		if (!pSkill)
			continue;
		if (!me.m_SkillList.CanCast(nSkill, dwNow))
			continue;
		if (!me.Cost(pSkill->GetSkillCostType(), pSkill->GetSkillCost(&me), TRUE, TRUE))
			continue;
		int nRadius = pSkill->GetAttackRadius();
		if (nRadius <= 0)
			nRadius = 64;
		if (!s_bPTAFRotate)
		{
			nBest = nSkill;
			nBestRadius = nRadius;
			bBestOnTarget = bOnTarget;
			break;
		}
		BOOL bIn = nDist >= 0 && nDist <= nRadius;
		int nWait = pSkill->GetDelayPerCast(me.m_bRideHorse);
		DWORD uUsed = PTAF_LastUsed(nSkill);
		BOOL bBetter;
		if (!nBest)
			bBetter = TRUE;
		else if (bIn != bBestIn)
			bBetter = bIn;
		else if (!bIn)
			bBetter = nRadius > nBestRadius;
		else if ((nWait > 0) != (nBestWait > 0))
			bBetter = nWait > 0;
		else
			bBetter = (int)(uUsed - uBestUsed) < 0;
		if (bBetter)
		{
			nBest = nSkill;
			nBestRadius = nRadius;
			nBestWait = nWait;
			bBestIn = bIn;
			bBestOnTarget = bOnTarget;
			uBestUsed = uUsed;
		}
	}
	if (!nBest || !me.SetActiveSkill(me.m_SkillList.FindSame(nBest)))
		return 0;
	*pnRadius = nBestRadius;
	*pbOnTarget = bBestOnTarget;
	return nBest;
}

// Same calls as a click on the ground (KPlayer::ProcessMouse) / KNpcAI::FollowPeople, rate limited.
static void PTAF_MoveTo(int nMe, int x, int y, DWORD uNow)
{
	KPlayer& pl = Player[CLIENT_PLAYER_INDEX];
	if (uNow - s_uPTAFLastMove < PTAF_MOVE_GAP_MS)
		return;
	if (pl.m_nSendMoveFrames < defMAX_PLAYER_SEND_MOVE_FRAME)
		return;
	if ((Npc[nMe].m_Doing == do_run || Npc[nMe].m_Doing == do_walk) &&
		PTAF_D2(x, y, s_nPTAFLastDestX, s_nPTAFLastDestY) < 32.0 * 32.0)
		return;     // already on the way there
	if (pl.m_RunStatus)
	{
		Npc[nMe].SendCommand(do_run, x, y);
		SendClientCmdRun(x, y);
	}
	else
	{
		Npc[nMe].SendCommand(do_walk, x, y);
		SendClientCmdWalk(x, y);
	}
	pl.m_nSendMoveFrames = 0;
	s_uPTAFLastMove = uNow;
	s_nPTAFLastDestX = x;
	s_nPTAFLastDestY = y;
}

static void PTAF_GoHome(int nMe, DWORD uNow)
{
	int x, y;
	Npc[nMe].GetMpsPos(&x, &y);
	if (PTAF_D2(x, y, s_nPTAFHomeX, s_nPTAFHomeY) <= (double)PTAF_HOME_SLACK * PTAF_HOME_SLACK)
		return;
	PTAF_MoveTo(nMe, s_nPTAFHomeX, s_nPTAFHomeY, uNow);
}

static void PTAF_Engage(int nMe, int t, DWORD uNow)
{
	KNpc& me = Npc[nMe];
	int nRadius = 0;
	BOOL bOnTarget = TRUE;
	int nDist = NpcSet.GetDistance(nMe, t);
	if (nDist < 0)
	{
		PTAF_DropTarget();
		return;
	}
	int nSkill = PTAF_PickSkill(nMe, nDist, &nRadius, &bOnTarget);
	if (!nSkill)
	{
		// Nothing castable right now (cooldown, mana): wait in range, otherwise close in.
		nRadius = me.m_CurrentAttackRadius > 0 ? me.m_CurrentAttackRadius : 64;
	}
	if (nDist <= nRadius)
	{
		s_uPTAFChaseSince = 0;
		if (!nSkill || uNow - s_uPTAFLastSkill < PTAF_SKILL_GAP_MS)
			return;
		if (bOnTarget)
		{
			me.SendCommand(do_skill, nSkill, -1, t);
			SendClientCmdSkill(nSkill, -1, Npc[t].m_dwID);
		}
		else
		{
			int x, y;
			Npc[t].GetMpsPos(&x, &y);
			me.SendCommand(do_skill, nSkill, x, y);
			SendClientCmdSkill(nSkill, x, y);
		}
		s_uPTAFLastSkill = uNow;
		PTAF_MarkUsed(nSkill, uNow);    // daosi: rotation bookkeeping
		return;
	}
	if (s_nPTAFMode == 3)
	{
		// Stay put: do not chase; monsters inside the area come to us. Keep on the spot.
		PTAF_GoHome(nMe, uNow);
		return;
	}
	if (!s_uPTAFChaseSince)
		s_uPTAFChaseSince = uNow;
	else if (uNow - s_uPTAFChaseSince > PTAF_CHASE_GIVEUP_MS)
	{
		PTAF_Ignore(Npc[t].m_dwID, uNow);   // blocked by a wall or kiting: try another one
		PTAF_DropTarget();
		return;
	}
	int x, y;
	Npc[t].GetMpsPos(&x, &y);
	PTAF_MoveTo(nMe, x, y, uNow);
}

// First red/blue (or both) potion found in the quick bar (pos_immediacy), used like a quick-bar click.
static BOOL PTAF_UseQuickPotion(int nDetailA, int nDetailB)
{
	KPlayer& pl = Player[CLIENT_PLAYER_INDEX];
	int nGuard = 0;
	for (PlayerItem* p = pl.m_ItemList.GetFirstItem(); p && nGuard < 1000; p = pl.m_ItemList.GetNextItem(), nGuard++)
	{
		if (p->nPlace != pos_immediacy || p->nIdx <= 0 || p->nIdx >= MAX_ITEM)
			continue;
		if (Item[p->nIdx].GetGenre() != item_medicine)
			continue;
		int nDetail = Item[p->nIdx].GetDetailType();
		if (nDetail != nDetailA && nDetail != nDetailB)
			continue;
		ItemPos sPos;
		sPos.nPlace = p->nPlace;
		sPos.nX = p->nX;
		sPos.nY = p->nY;
		pl.ApplyUseItem(p->nIdx, sPos);
		return TRUE;
	}
	return FALSE;
}

static void PTAF_Potions(int nMe, DWORD uNow)
{
	KNpc& me = Npc[nMe];
	if (me.m_CurrentLifeMax > 0 && me.m_CurrentLife * 100 / me.m_CurrentLifeMax < PTAF_HP_PERCENT &&
		uNow - s_uPTAFLastHp >= PTAF_POTION_GAP_MS)
	{
		PTAF_UseQuickPotion(medicine_blood, medicine_both);
		s_uPTAFLastHp = uNow;   // also throttles the scan when the quick bar has none
	}
	if (me.m_CurrentManaMax > 0 && me.m_CurrentMana * 100 / me.m_CurrentManaMax < PTAF_MP_PERCENT &&
		uNow - s_uPTAFLastMp >= PTAF_POTION_GAP_MS)
	{
		PTAF_UseQuickPotion(medicine_mana, medicine_both);
		s_uPTAFLastMp = uNow;
	}
}

static void PTAF_Stop(const char* szReason)
{
	if (!s_nPTAFMode)
		return;
	s_nPTAFMode = 0;
	s_bPTAFPaused = FALSE;
	PTAF_DropTarget();
	PTAF_Say(PTAF_S_OFF, szReason, TRUE);
}

// daosi: "<prefix> - luan phien N chieu (Alt+R bat/tat)" or "<prefix> - 1 chieu (Alt+R: luan phien)".
static const char* PTAF_RotateSuffix(const char* szPrefix)
{
	static char s_szPTAFRot[160];
	int nCount = 1;
	int nMe = PTAF_Me();
	if (s_bPTAFRotate && nMe)
	{
		int aSkill[PTAF_LIST_MAX];
		nCount = PTAF_SkillList(Npc[nMe], aSkill);
	}
	char szTail[96];
	if (s_bPTAFRotate && nCount >= 2)
		_snprintf(szTail, sizeof(szTail) - 1, PTAF_S_ROT_N, nCount);
	else
		_snprintf(szTail, sizeof(szTail) - 1, "%s", PTAF_S_ROT_ONE);
	szTail[sizeof(szTail) - 1] = 0;
	_snprintf(s_szPTAFRot, sizeof(s_szPTAFRot) - 1, "%s%s", szPrefix ? szPrefix : "", szTail);
	s_szPTAFRot[sizeof(s_szPTAFRot) - 1] = 0;
	return s_szPTAFRot;
}

static int PTAF_Start(int nMode)
{
	int nMe = PTAF_Me();
	if (!nMe || SubWorld[0].m_SubWorldID <= 0)
		return 0;
	KNpc& me = Npc[nMe];
	if (me.m_Doing == do_death || me.m_Doing == do_revive || me.m_CurrentLife <= 0)
		return 0;
	if (me.m_FightMode == enumFightNone)
	{
		PTAF_Say(PTAF_S_NOSAFE, NULL, TRUE);
		return 0;
	}
	s_nPTAFMode = nMode;
	me.GetMpsPos(&s_nPTAFHomeX, &s_nPTAFHomeY);
	s_nPTAFWorldID = SubWorld[0].m_SubWorldID;
	s_uPTAFDialogToken = Player[CLIENT_PLAYER_INDEX].m_UiDialogToken;
	s_bPTAFPaused = FALSE;
	s_uPTAFLastThink = 0;
	s_uPTAFLastSkill = 0;
	s_uPTAFLastMove = 0;
	s_nPTAFLastDestX = s_nPTAFHomeX;
	s_nPTAFLastDestY = s_nPTAFHomeY;
	memset(s_dwPTAFIgnoreID, 0, sizeof(s_dwPTAFIgnoreID));
	memset(s_uPTAFIgnoreUntil, 0, sizeof(s_uPTAFIgnoreUntil));
	PTAF_DropTarget();
	// One driver at a time: the old TamLTM auto (KPlayerAI, settings window not shipped) stays off,
	// and a pending click-follow target is dropped.
	Player[CLIENT_PLAYER_INDEX].m_cAI.m_bIsActive = FALSE;
	me.m_nPeopleIdx = 0;
	PTAF_Say(PTAF_S_ON, PTAF_RotateSuffix(nMode == 1 ? PTAF_S_M1 : (nMode == 2 ? PTAF_S_M2 : PTAF_S_M3)), TRUE);
	return nMode;
}

// UI entry (KCoreShell::PAIOperation). uMode: 1/2/3 toggles that mode, 0 turns off, PTAF_QUERY asks.
int PTAutoFight_Operation(unsigned int uMode, int nParam, int nParam1)
{
	(void)nParam;
	(void)nParam1;
	if (uMode == PTAF_QUERY)
		return s_nPTAFMode;
	// daosi: rotation toggle and the quick-key skill list pushed by the UI.
	if (uMode == PTAF_OP_ROTATE_QUERY)
		return s_bPTAFRotate;
	if (uMode == PTAF_OP_LIST_CLEAR)
	{
		s_nPTAFUiSkill = 0;
		return 0;
	}
	if (uMode == PTAF_OP_LIST_ADD)
	{
		PTAF_AddUnique(s_aPTAFUiSkill, &s_nPTAFUiSkill, nParam);
		return s_nPTAFUiSkill;
	}
	if (uMode == PTAF_OP_ROTATE)
	{
		s_bPTAFRotate = !s_bPTAFRotate;
		if (s_bPTAFRotate)
			PTAF_Say(PTAF_RotateSuffix(PTAF_S_ROT_ON), NULL, TRUE);
		else
			PTAF_Say(PTAF_S_ROT_OFF, NULL, TRUE);
		return s_bPTAFRotate;
	}
	if (uMode == 0 || uMode > 3 || s_nPTAFMode == (int)uMode)
	{
		PTAF_Stop(NULL);
		return 0;
	}
	s_nPTAFMode = 0;    // switching mode: Start() announces the new one
	return PTAF_Start((int)uMode);
}

// A manual click or drag in the game world: pause, then resume from wherever the player is.
void PTAutoFight_OnManualInput()
{
	if (!s_nPTAFMode)
		return;
	if (!s_bPTAFPaused)
		PTAF_Say(PTAF_S_PAUSE, NULL, FALSE);
	s_bPTAFPaused = TRUE;
	s_uPTAFPauseUntil = IR_GetCurrentTime() + PTAF_PAUSE_MS;
	PTAF_DropTarget();
}

void PTAutoFight_Tick()
{
	if (!s_nPTAFMode)
		return;
	int nMe = PTAF_Me();
	if (!nMe)
	{
		PTAF_Stop(NULL);    // no player NPC (loading a map, logging out): plain "OFF"
		return;
	}
	KPlayer& pl = Player[CLIENT_PLAYER_INDEX];
	KNpc& me = Npc[nMe];
	if (SubWorld[0].m_SubWorldID != s_nPTAFWorldID)
	{
		PTAF_Stop(PTAF_S_R_MAP);
		return;
	}
	if (me.m_Doing == do_death || me.m_Doing == do_revive || me.m_CurrentLife <= 0)
	{
		PTAF_Stop(PTAF_S_R_DEATH);
		return;
	}
	if (me.m_FightMode == enumFightNone)
	{
		PTAF_Stop(PTAF_S_R_SAFE);
		return;
	}
	if (pl.m_UiDialogToken != s_uPTAFDialogToken)
	{
		s_uPTAFDialogToken = pl.m_UiDialogToken;
		if (s_uPTAFDialogToken)
		{
			PTAF_Stop(PTAF_S_R_DIALOG);   // a new server dialog was shown
			return;
		}
	}
	if (pl.CheckTrading())
	{
		PTAF_Stop(PTAF_S_R_TRADE);
		return;
	}
	DWORD uNow = IR_GetCurrentTime();
	if (s_bPTAFPaused)
	{
		if ((int)(s_uPTAFPauseUntil - uNow) > 0)
			return;
		s_bPTAFPaused = FALSE;
		me.GetMpsPos(&s_nPTAFHomeX, &s_nPTAFHomeY);     // new start spot after manual movement
	}
	if (uNow - s_uPTAFLastThink < PTAF_THINK_MS)
		return;
	s_uPTAFLastThink = uNow;

	PTAF_Potions(nMe, uNow);
	if (!PTAF_Ready(nMe))
		return;

	int t = s_nPTAFTarget;
	if (t && (t <= 0 || t >= MAX_NPC || Npc[t].m_dwID != s_dwPTAFTargetID ||
		!PTAF_IsCandidate(nMe, t, uNow) || !PTAF_InArea(nMe, t)))
	{
		PTAF_DropTarget();      // dead, gone, left the area: pick the next one
		t = 0;
	}
	if (!t)
	{
		t = PTAF_FindTarget(nMe, uNow);
		if (!t)
		{
			PTAF_GoHome(nMe, uNow);
			return;
		}
		s_nPTAFTarget = t;
		s_dwPTAFTargetID = Npc[t].m_dwID;
		s_nPTAFTargetLife = Npc[t].m_CurrentLife;
		s_uPTAFLifeAt = uNow;
		s_uPTAFChaseSince = 0;
	}
	if (Npc[t].m_CurrentLife != s_nPTAFTargetLife)
	{
		s_nPTAFTargetLife = Npc[t].m_CurrentLife;
		s_uPTAFLifeAt = uNow;
	}
	else if (uNow - s_uPTAFLifeAt > PTAF_NOHIT_GIVEUP_MS)
	{
		PTAF_Ignore(Npc[t].m_dwID, uNow);   // no damage landing (blocked, immune, desync): skip it
		PTAF_DropTarget();
		return;
	}
	PTAF_Engage(nMe, t, uNow);
}

#endif // PHONGTHAN_AUTOFIGHT_INL
#endif // _SERVER
