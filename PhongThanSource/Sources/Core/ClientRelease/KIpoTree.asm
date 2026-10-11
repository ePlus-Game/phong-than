	TITLE	D:\Lam game phong than\PhongThanSource\Sources\Core\Src\Scene\KIpoTree.cpp
	.386P
include listing.inc
if @Version gt 510
.model FLAT
else
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT DWORD USE32 PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT DWORD USE32 PUBLIC 'BSS'
_BSS	ENDS
$$SYMBOLS	SEGMENT BYTE USE32 'DEBSYM'
$$SYMBOLS	ENDS
$$TYPES	SEGMENT BYTE USE32 'DEBTYP'
$$TYPES	ENDS
_TLS	SEGMENT DWORD USE32 PUBLIC 'TLS'
_TLS	ENDS
;	COMDAT ??_C@_00A@?$AA@
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT ??8@YAHABU_GUID@@0@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??1KNode@@UAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??_GKNode@@UAEPAXI@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??0KNode@@QAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?GetNext@KNode@@QAEPAV1@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?GetPrev@KNode@@QAEPAV1@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?InsertBefore@KNode@@QAEXPAV1@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?InsertAfter@KNode@@QAEXPAV1@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?Remove@KNode@@QAEXXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?GetName@KStrNode@@UAEPADXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?SetName@KStrNode@@UAEXPAD@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?GetHead@KList@@QAEPAVKNode@@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?AddTail@KList@@QAEXPAVKNode@@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??_GKCacheNode@@UAEPAXI@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??1KStrNode@@UAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??1KCacheNode@@UAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?GetMemPtr@KMemClass@@QAEPAXXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??1KITabFile@@UAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?PhongThanValidateWireHeader@@YAHPBUPHONGTHAN_WIRE_HEADER@@I@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?PhongThanWorldPositionValid@@YAHHH@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?PhongThanWorldFixedPacket@@YAHPBXIGGI@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?PhongThanWireTextTerminated@@YAHPBDI@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?PhongThanVisualPartValid@@YAHABUPHONGTHAN_VISUAL_PART_WIRE@@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?Clear@KLockItem@@QAEXXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?Release@tagSHOW_MSG_SYNC@@QAEXXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??1KScriptNode@@UAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?Release@SOBJ_LIGHT_DATA@@QAEXXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?GetCount@KLinkArray@@QAEHXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?PhongThanCharacterExpectedStateSize@@YAIPBUPHONGTHAN_CHARACTER_STATE_HEADER@@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?PhongThanCharacterFightSkills@@YAPAUPHONGTHAN_CHARACTER_SKILL_RECORD@@PAUPHONGTHAN_CHARACTER_STATE_HEADER@@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?PhongThanCharacterFightSkills@@YAPBUPHONGTHAN_CHARACTER_SKILL_RECORD@@PBUPHONGTHAN_CHARACTER_STATE_HEADER@@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?PhongThanCharacterStateSkills@@YAPAUPHONGTHAN_CHARACTER_SKILL_RECORD@@PAUPHONGTHAN_CHARACTER_STATE_HEADER@@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?PhongThanCharacterStateSkills@@YAPBUPHONGTHAN_CHARACTER_SKILL_RECORD@@PBUPHONGTHAN_CHARACTER_STATE_HEADER@@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?PhongThanCharacterTasks@@YAPAUPHONGTHAN_CHARACTER_TASK_RECORD@@PAUPHONGTHAN_CHARACTER_STATE_HEADER@@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?PhongThanCharacterTasks@@YAPBUPHONGTHAN_CHARACTER_TASK_RECORD@@PBUPHONGTHAN_CHARACTER_STATE_HEADER@@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??_GKIndexNode@@UAEPAXI@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??1KIndexNode@@UAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?Clear@SACTTABLEOFF@@QAEXXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?Clear@SECTINFO@KNpcResNode@@QAEXXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??0KWorldMsgNode@@QAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??_GKWorldMsgNode@@UAEPAXI@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??1KWorldMsgNode@@UAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?Remove@KMissleMagicAttribsData@@AAEXXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??1ISkill@@UAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?IsTargetSelf@ISkill@@UBEHXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?IsAura@ISkill@@UBEHXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?IsPhysical@ISkill@@UBEHXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?IsExp@ISkill@@UAEHXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?IsBase@ISkill@@UAEHXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?GetSkillLevelUpScriptId@ISkill@@UBEKXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?GetDelayPerCast@ISkill@@UBEHH@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?GetSkillSeries@ISkill@@UBEHXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??_GISkill@@UAEPAXI@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?GetSkill@KSkillManager@@QAEPAVISkill@@HH@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?SetColor@KLColor@@QAEXK@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?Scale@KLColor@@QAEXM@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?GetColor@KLColor@@QAEKXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT _wmemchr
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT _wmemcmp
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT _wmemcpy
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT _wmemmove
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT _wmemset
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?eof@?$char_traits@G@std@@SAGXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?assign@?$char_traits@D@std@@SAXAADABD@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?length@?$char_traits@D@std@@SAIPBD@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?copy@?$char_traits@D@std@@SAPADPADPBDI@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?move@?$char_traits@D@std@@SAPADPADPBDI@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?eof@?$char_traits@D@std@@SAHXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??1bad_exception@std@@UAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??0bad_exception@std@@QAE@ABV01@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??1bad_alloc@std@@UAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??0bad_alloc@std@@QAE@ABV01@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??2@YAPAXIPAX@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??0logic_error@std@@QAE@ABV?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@1@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??1logic_error@std@@UAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?what@logic_error@std@@UBEPBDXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??0logic_error@std@@QAE@ABV01@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??1domain_error@std@@UAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??0domain_error@std@@QAE@ABV01@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??1invalid_argument@std@@UAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?_Doraise@invalid_argument@std@@MBEXXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??_Ginvalid_argument@std@@UAEPAXI@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??0invalid_argument@std@@QAE@ABV01@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??1length_error@std@@UAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??0length_error@std@@QAE@ABV01@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??1out_of_range@std@@UAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??0out_of_range@std@@QAE@ABV01@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??0runtime_error@std@@QAE@ABV?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@1@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??1runtime_error@std@@UAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??0runtime_error@std@@QAE@ABV01@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??1overflow_error@std@@UAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??0overflow_error@std@@QAE@ABV01@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??1underflow_error@std@@UAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??0underflow_error@std@@QAE@ABV01@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??1range_error@std@@UAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??0range_error@std@@QAE@ABV01@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?Breath@KLightBase@@UAEXXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??0KSelfBreathLight@@QAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??0KLightBase@@QAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?Breath@KSelfBreathLight@@UAEXXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??0KIpoTree@@QAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??1KIpoTree@@QAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?Paint@KIpoTree@@QAEXPAUtagRECT@@W4IPOT_RENDER_LAYER@@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?Breathe@KIpoTree@@QAEXXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?Clear@KIpoTree@@QAEXXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??_GKIpotBranch@@QAEPAXI@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?RemoveRtoGroupWithPermanentLeaf@KIpoTree@@AAEXXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?AddBranch@KIpoTree@@QAEXPAUKIpotBuildinObj@@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?Fell@KIpoTree@@QAEXXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?AddLeafLine@KIpoTree@@QAEXPAUKIpotBuildinObj@@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?AddLeafPoint@KIpoTree@@QAEXPAUKIpotLeaf@@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?PluckRto@KIpoTree@@QAEXPAUKIpotRuntimeObj@@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?SetPermanentBranchPos@KIpoTree@@QAEXHHH@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?StrewRtoLeafs@KIpoTree@@QAEXAAUtagRECT@@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?ObjectsCallback@KIpoTree@@CAXPAXPAUKIpotLeaf@@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?FillLineObstacle@KIpoTree@@AAEXHHHHH@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?RenderLightMap@KIpoTree@@QAEXXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?CanLighting@KIpoTree@@AAE_NHHHH@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?AddBuildinLight@KIpoTree@@QAEXPAUKBuildInLightInfo@@H@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?EnableBioLights@KIpoTree@@QAEX_N@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?EnableDynamicLights@KIpoTree@@QAEX_N@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??0?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@std@@QAE@ABV01@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_??1?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@std@@QAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?c_str@?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@std@@QBEPBDXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??0?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QAE@ABV?$allocator@PAVKLightBase@@@1@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??1?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?begin@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QAE?AViterator@12@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?end@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QAE?AViterator@12@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?size@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QBEIXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?push_back@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QAEXABQAVKLightBase@@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?erase@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QAE?AViterator@12@V312@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?clear@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QAEXXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??0iterator@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??Diterator@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QBEAAPAVKLightBase@@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??Eiterator@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QAEAAV012@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??9iterator@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QBE_NABV012@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?assign@?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@std@@QAEAAV12@ABV12@II@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?_Nullstr@?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@std@@CAPBDXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?_Tidy@?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@std@@AAEX_N@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?insert@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QAE?AViterator@12@V312@ABQAVKLightBase@@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?erase@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QAE?AViterator@12@V312@0@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?_Buynode@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@IAEPAU_Node@12@PAU312@0@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?_Freenode@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@IAEXPAU_Node@12@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?_Next@_Acc@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@SAAAPAU_Node@23@PAU423@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?_Prev@_Acc@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@SAAAPAU_Node@23@PAU423@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?_Value@_Acc@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@SAAAPAVKLightBase@@PAU_Node@23@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?destroy@?$allocator@PAVKLightBase@@@std@@QAEXPAPAVKLightBase@@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??0const_iterator@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QAE@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?_Mynode@const_iterator@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QBEPAU_Node@23@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??0iterator@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QAE@PAU_Node@12@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??Eiterator@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QAE?AV012@H@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??8iterator@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QBE_NABV012@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?erase@?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@std@@QAEAAV12@II@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?size@?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@std@@QBEIXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?capacity@?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@std@@QBEIXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?_Eos@?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@std@@AAEXI@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?_Grow@?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@std@@AAE_NI_N@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?_Refcnt@?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@std@@AAEAAEPBD@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?deallocate@?$allocator@D@std@@QAEXPAXI@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?_Charalloc@?$allocator@PAVKLightBase@@@std@@QAEPADI@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?deallocate@?$allocator@PAVKLightBase@@@std@@QAEXPAXI@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?construct@?$allocator@PAVKLightBase@@@std@@QAEXPAPAVKLightBase@@ABQAV3@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??0const_iterator@?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QAE@PAU_Node@12@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?max_size@?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@std@@QBEIXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?_Copy@?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@std@@AAEXI@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?_Split@?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@std@@AAEXXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?assign@?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@std@@QAEAAV12@PBD@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?allocate@?$allocator@D@std@@QAEPADIPBX@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?max_size@?$allocator@D@std@@QBEIXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT __imp_?assign@?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@std@@QAEAAV12@PBDI@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??8std@@YA_NABV?$allocator@D@0@0@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?_Destroy@std@@YAXPAPAVKLightBase@@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?_Allocate@std@@YAPADHPAD@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?_Construct@std@@YAXPAPAVKLightBase@@ABQAV2@@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ??_7KNode@@6B@
CONST	SEGMENT DWORD USE32 PUBLIC 'CONST'
CONST	ENDS
;	COMDAT ??_R0?AVruntime_error@std@@@8
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT __CTA2?AVlogic_error@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __CTA3?AVrange_error@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT ??_R0?AVout_of_range@std@@@8
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT ??_7KIndexNode@@6B@
CONST	SEGMENT DWORD USE32 PUBLIC 'CONST'
CONST	ENDS
;	COMDAT __CT??_R0?AVoverflow_error@std@@@8??0overflow_error@std@@QAE@ABV01@@Z28
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __CTA2?AVruntime_error@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __TI3?AVunderflow_error@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __CTA3?AVoverflow_error@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __CT??_R0?AVrange_error@std@@@8??0range_error@std@@QAE@ABV01@@Z28
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT ??_R0?AVbad_alloc@std@@@8
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT ??_7KWorldMsgNode@@6B@
CONST	SEGMENT DWORD USE32 PUBLIC 'CONST'
CONST	ENDS
;	COMDAT __CT??_R0?AVlength_error@std@@@8??0length_error@std@@QAE@ABV01@@Z28
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __TI3?AVlength_error@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT ??_R0?AVlength_error@std@@@8
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT __CTA3?AVdomain_error@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __CTA2?AVbad_exception@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __TI2?AVruntime_error@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __TI3?AVout_of_range@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __CTA3?AVunderflow_error@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __TI3?AVrange_error@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT ??_R0?AVoverflow_error@std@@@8
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT __CTA2?AVbad_alloc@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT ??_7invalid_argument@std@@6B@
CONST	SEGMENT DWORD USE32 PUBLIC 'CONST'
CONST	ENDS
;	COMDAT __TI3?AVinvalid_argument@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __CT??_R0?AVbad_alloc@std@@@8??0bad_alloc@std@@QAE@ABV01@@Z12
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT ??_R0?AVlogic_error@std@@@8
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT ??_R0?AVexception@@@8
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT __CT??_R0?AVout_of_range@std@@@8??0out_of_range@std@@QAE@ABV01@@Z28
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __TI3?AVdomain_error@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __CTA3?AVinvalid_argument@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT ??_7KCacheNode@@6B@
CONST	SEGMENT DWORD USE32 PUBLIC 'CONST'
CONST	ENDS
;	COMDAT __CT??_R0?AVexception@@@8??0exception@@QAE@ABV0@@Z12
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __CT??_R0?AVunderflow_error@std@@@8??0underflow_error@std@@QAE@ABV01@@Z28
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT ??_R0?AVdomain_error@std@@@8
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT __CTA3?AVlength_error@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT ??_7ISkill@@6B@
CONST	SEGMENT DWORD USE32 PUBLIC 'CONST'
CONST	ENDS
;	COMDAT ??_R0?AVunderflow_error@std@@@8
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT ??_7KLightBase@@6B@
CONST	SEGMENT DWORD USE32 PUBLIC 'CONST'
CONST	ENDS
;	COMDAT __CT??_R0?AVinvalid_argument@std@@@8??0invalid_argument@std@@QAE@ABV01@@Z28
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __CT??_R0?AVbad_exception@std@@@8??0bad_exception@std@@QAE@ABV01@@Z12
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __TI2?AVlogic_error@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __TI3?AVoverflow_error@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __CT??_R0?AVdomain_error@std@@@8??0domain_error@std@@QAE@ABV01@@Z28
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __CT??_R0?AVruntime_error@std@@@8??0runtime_error@std@@QAE@ABV01@@Z28
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT ??_R0?AVinvalid_argument@std@@@8
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT ??_R0?AVrange_error@std@@@8
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT __TI2?AVbad_exception@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __CT??_R0?AVlogic_error@std@@@8??0logic_error@std@@QAE@ABV01@@Z28
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT __TI2?AVbad_alloc@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
;	COMDAT ??_7KSelfBreathLight@@6B@
CONST	SEGMENT DWORD USE32 PUBLIC 'CONST'
CONST	ENDS
;	COMDAT ??_R0?AVbad_exception@std@@@8
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT __CTA3?AVout_of_range@std@@
xdata$x	SEGMENT DWORD USE32 PUBLIC 'CONST'
xdata$x	ENDS
FLAT	GROUP _DATA, CONST, _BSS, xdata$x
	ASSUME	CS: FLAT, DS: FLAT, SS: FLAT
endif
_DATA	SEGMENT
_?nObstacleID@?1??ObjectsCallback@KIpoTree@@CAXPAXPAUKIpotLeaf@@@Z@4HA DD 01H
_DATA	ENDS
PUBLIC	??0KSelfBreathLight@@QAE@XZ			; KSelfBreathLight::KSelfBreathLight
PUBLIC	?Breath@KSelfBreathLight@@UAEXXZ		; KSelfBreathLight::Breath
PUBLIC	??_7KSelfBreathLight@@6B@			; KSelfBreathLight::`vftable'
EXTRN	__imp__timeGetTime@0:NEAR
;	COMDAT ??_7KSelfBreathLight@@6B@
; File D:\Lam game phong than\PhongThanSource\Sources\Core\Src\Scene\KIpoTree.cpp
CONST	SEGMENT
??_7KSelfBreathLight@@6B@ DD FLAT:?Breath@KSelfBreathLight@@UAEXXZ ; KSelfBreathLight::`vftable'
CONST	ENDS
;	COMDAT ??0KSelfBreathLight@@QAE@XZ
_TEXT	SEGMENT
??0KSelfBreathLight@@QAE@XZ PROC NEAR			; KSelfBreathLight::KSelfBreathLight, COMDAT

; 25   : {

	push	esi
	mov	esi, ecx
	mov	DWORD PTR [esi], OFFSET FLAT:??_7KSelfBreathLight@@6B@ ; KSelfBreathLight::`vftable'

; 26   : 	nDir = 1;

	mov	DWORD PTR [esi+44], 1

; 27   : 	dwLastBreathTime = timeGetTime();

	call	DWORD PTR __imp__timeGetTime@0
	mov	DWORD PTR [esi+48], eax

; 28   : }

	mov	eax, esi
	pop	esi
	ret	0
??0KSelfBreathLight@@QAE@XZ ENDP			; KSelfBreathLight::KSelfBreathLight
_TEXT	ENDS
EXTRN	__ftol:NEAR
EXTRN	__fltused:NEAR
;	COMDAT ?Breath@KSelfBreathLight@@UAEXXZ
_TEXT	SEGMENT
?Breath@KSelfBreathLight@@UAEXXZ PROC NEAR		; KSelfBreathLight::Breath, COMDAT

; 31   : {

	sub	esp, 12					; 0000000cH
	push	esi
	push	edi
	mov	esi, ecx

; 32   : 	DWORD dwCurTime = timeGetTime();

	call	DWORD PTR __imp__timeGetTime@0

; 33   : 	
; 34   : 	fRadius += (dwCurTime - dwLastBreathTime) / fCycle * (fMaxRange - fMinRange) * nDir * 2;

	mov	edx, DWORD PTR [esi+48]
	mov	edi, eax
	sub	eax, edx
	mov	DWORD PTR -8+[esp+24], 0
	mov	DWORD PTR -8+[esp+20], eax
	mov	ecx, DWORD PTR [esi+44]
	fild	QWORD PTR -8+[esp+20]
	mov	DWORD PTR -12+[esp+20], ecx

; 35   : 	if(nDir == 1 && fRadius > fMaxRange)

	cmp	ecx, 1
	fdiv	DWORD PTR [esi+40]
	fld	DWORD PTR [esi+32]
	fsub	DWORD PTR [esi+28]
	fmulp	ST(1), ST(0)
	fimul	DWORD PTR -12+[esp+20]
	fadd	ST(0), ST(0)
	fadd	DWORD PTR [esi+36]
	fst	DWORD PTR [esi+36]
	jne	SHORT $L90090
	fcom	DWORD PTR [esi+32]
	fnstsw	ax
	test	ah, 65					; 00000041H
	jne	SHORT $L90090

; 36   : 	{
; 37   : 		nDir = -1;
; 38   : 		fRadius = fMaxRange;

	mov	ecx, DWORD PTR [esi+32]
	mov	DWORD PTR [esi+44], -1
	fstp	ST(0)
	mov	DWORD PTR [esi+36], ecx

; 44   : 	}
; 45   : 	m_nRadius = (int)fRadius;

	fld	DWORD PTR [esi+36]
	call	__ftol

; 46   : 	dwLastBreathTime = dwCurTime;

	mov	DWORD PTR [esi+48], edi
	mov	DWORD PTR [esi+24], eax
	pop	edi
	pop	esi

; 47   : }

	add	esp, 12					; 0000000cH
	ret	0
$L90090:

; 39   : 	}
; 40   : 	else if(nDir == -1 && fRadius < fMinRange)

	cmp	ecx, -1
	jne	SHORT $L91178
	fcomp	DWORD PTR [esi+28]
	fnstsw	ax
	test	ah, 1
	je	SHORT $L90092

; 41   : 	{
; 42   : 		nDir = 1;
; 43   : 		fRadius = fMinRange;

	mov	edx, DWORD PTR [esi+28]
	mov	DWORD PTR [esi+44], 1
	mov	DWORD PTR [esi+36], edx

; 44   : 	}
; 45   : 	m_nRadius = (int)fRadius;

	fld	DWORD PTR [esi+36]
	call	__ftol

; 46   : 	dwLastBreathTime = dwCurTime;

	mov	DWORD PTR [esi+48], edi
	mov	DWORD PTR [esi+24], eax
	pop	edi
	pop	esi

; 47   : }

	add	esp, 12					; 0000000cH
	ret	0
$L91178:

; 41   : 	{
; 42   : 		nDir = 1;
; 43   : 		fRadius = fMinRange;

	fstp	ST(0)
$L90092:

; 44   : 	}
; 45   : 	m_nRadius = (int)fRadius;

	fld	DWORD PTR [esi+36]
	call	__ftol

; 46   : 	dwLastBreathTime = dwCurTime;

	mov	DWORD PTR [esi+48], edi
	mov	DWORD PTR [esi+24], eax
	pop	edi
	pop	esi

; 47   : }

	add	esp, 12					; 0000000cH
	ret	0
?Breath@KSelfBreathLight@@UAEXXZ ENDP			; KSelfBreathLight::Breath
_TEXT	ENDS
PUBLIC	??0KIpoTree@@QAE@XZ				; KIpoTree::KIpoTree
PUBLIC	??1?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QAE@XZ ; std::list<KLightBase *,std::allocator<KLightBase *> >::~list<KLightBase *,std::allocator<KLightBase *> >
EXTRN	__except_list:DWORD
EXTRN	___CxxFrameHandler:NEAR
EXTRN	??2@YAPAXI@Z:NEAR				; operator new
EXTRN	??0KIpotBranch@@QAE@XZ:NEAR			; KIpotBranch::KIpotBranch
EXTRN	??1KIpotBranch@@QAE@XZ:NEAR			; KIpotBranch::~KIpotBranch
;	COMDAT xdata$x
; File D:\VisualStudio6\VisualStudio6portable-langman.congdongcviet\Microsoft Visual Studio\VC98\INCLUDE\list
xdata$x	SEGMENT
$T91252	DD	019930520H
	DD	02H
	DD	FLAT:$T91255
	DD	2 DUP(00H)
	DD	2 DUP(00H)
	ORG $+4
$T91255	DD	0ffffffffH
	DD	FLAT:$L91186
	DD	00H
	DD	FLAT:$L91187
xdata$x	ENDS
;	COMDAT ??0KIpoTree@@QAE@XZ
_TEXT	SEGMENT
$T91183 = -17
__$EHRec$ = -12
_this$ = -16
??0KIpoTree@@QAE@XZ PROC NEAR				; KIpoTree::KIpoTree, COMDAT

; 51   : {

	push	-1
	push	$L91253
	mov	eax, DWORD PTR fs:__except_list
	push	eax
	mov	DWORD PTR fs:__except_list, esp
	sub	esp, 8
	push	ebx
	push	esi
	mov	esi, ecx
	push	edi
	mov	DWORD PTR _this$[esp+32], esi
	lea	ecx, DWORD PTR [esi+4]
	call	??0KIpotBranch@@QAE@XZ			; KIpotBranch::KIpotBranch
	mov	al, BYTE PTR $T91183[esp+32]
	xor	ebx, ebx
	push	12					; 0000000cH
	mov	DWORD PTR __$EHRec$[esp+44], ebx
	mov	BYTE PTR [esi+92272], al
	call	??2@YAPAXI@Z				; operator new
	mov	DWORD PTR [eax], eax
	mov	DWORD PTR [eax+4], eax
	mov	DWORD PTR [esi+92276], eax
	mov	DWORD PTR [esi+92280], ebx
	mov	al, 1

; 52   : 	m_pMainBranch = NULL;
; 53   : 	m_bProcessBioLights = true;
; 54   : 	m_bDynamicLighting = true;
; 55   : 	m_nCurrentTime = 0;
; 56   : 	m_bIsIndoor = false;
; 57   : 	m_dwAmbient = 0xff000000;
; 58   : 	memset(&m_PermanentLeaf, 0, sizeof(m_PermanentLeaf));

	mov	ecx, 6
	mov	BYTE PTR __$EHRec$[esp+44], al
	mov	BYTE PTR [esi+89], al
	mov	BYTE PTR [esi+90], al
	xor	eax, eax
	lea	edi, DWORD PTR [esi+52]
	mov	DWORD PTR [esi], ebx
	mov	DWORD PTR [esi+84], ebx
	mov	BYTE PTR [esi+88], bl
	mov	DWORD PTR [esi+92], -16777216		; ff000000H

; 59   : 
; 60   :     ptrdiff_t ulAddress;
; 61   : 
; 62   :     m_pbyLColorBase = new unsigned char [(sizeof(KLColor) * LIGHTING_GRID_WIDTH * LIGHTING_GRID_HEIGHT) + 255];

	push	37119					; 000090ffH
	rep stosd
	call	??2@YAPAXI@Z				; operator new
	mov	DWORD PTR [esi+73828], eax

; 63   :     _ASSERT(m_pbyLColorBase);
; 64   :     ulAddress = (ptrdiff_t)m_pbyLColorBase;
; 65   :     ulAddress = (ulAddress + 255) / 256 * 256;

	add	eax, 255				; 000000ffH
	cdq
	and	edx, 255				; 000000ffH

; 66   :     pLColor = (KLColor *)ulAddress;
; 67   : 
; 68   :     m_pby_ptpBase = new unsigned char [(sizeof(KLColor) * LIGHTING_GRID_WIDTH * LIGHTING_GRID_HEIGHT) + 255];

	push	37119					; 000090ffH
	add	eax, edx
	sar	eax, 8
	shl	eax, 8
	mov	DWORD PTR [esi+73824], eax
	call	??2@YAPAXI@Z				; operator new
	mov	DWORD PTR [esi+73836], eax

; 69   :     _ASSERT(m_pby_ptpBase);
; 70   :     ulAddress = (ptrdiff_t)m_pby_ptpBase;
; 71   :     ulAddress = (ulAddress + 255) / 256 * 256;

	add	eax, 255				; 000000ffH
	cdq
	and	edx, 255				; 000000ffH

; 72   :     ptp = (KLColor *)ulAddress;
; 73   : }

	mov	ecx, DWORD PTR __$EHRec$[esp+44]
	add	eax, edx
	add	esp, 12					; 0000000cH
	sar	eax, 8
	shl	eax, 8
	mov	DWORD PTR [esi+73832], eax
	mov	eax, esi
	pop	edi
	pop	esi
	pop	ebx
	mov	DWORD PTR fs:__except_list, ecx
	add	esp, 20					; 00000014H
	ret	0
_TEXT	ENDS
;	COMDAT text$x
text$x	SEGMENT
$L91186:
	mov	ecx, DWORD PTR _this$[ebp]
	add	ecx, 4
	jmp	??1KIpotBranch@@QAE@XZ			; KIpotBranch::~KIpotBranch
$L91187:
	mov	ecx, DWORD PTR _this$[ebp]
	add	ecx, 92272				; 00016870H
	jmp	??1?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QAE@XZ ; std::list<KLightBase *,std::allocator<KLightBase *> >::~list<KLightBase *,std::allocator<KLightBase *> >
$L91253:
	mov	eax, OFFSET FLAT:$T91252
	jmp	___CxxFrameHandler
text$x	ENDS
??0KIpoTree@@QAE@XZ ENDP				; KIpoTree::KIpoTree
PUBLIC	??1KIpoTree@@QAE@XZ				; KIpoTree::~KIpoTree
PUBLIC	?Clear@KIpoTree@@QAEXXZ				; KIpoTree::Clear
EXTRN	??3@YAXPAX@Z:NEAR				; operator delete
;	COMDAT xdata$x
; File D:\VisualStudio6\VisualStudio6portable-langman.congdongcviet\Microsoft Visual Studio\VC98\INCLUDE\xmemory
xdata$x	SEGMENT
$T91576	DD	019930520H
	DD	02H
	DD	FLAT:$T91579
	DD	2 DUP(00H)
	DD	2 DUP(00H)
	ORG $+4
$T91579	DD	0ffffffffH
	DD	FLAT:$L91264
	DD	00H
	DD	FLAT:$L91265
xdata$x	ENDS
;	COMDAT ??1KIpoTree@@QAE@XZ
_TEXT	SEGMENT
_this$ = -16
__$EHRec$ = -12
??1KIpoTree@@QAE@XZ PROC NEAR				; KIpoTree::~KIpoTree, COMDAT

; 77   : {

	push	-1
	push	$L91578
	mov	eax, DWORD PTR fs:__except_list
	push	eax
	mov	DWORD PTR fs:__except_list, esp
	push	ecx
	push	ebx
	push	ebp
	push	esi
	mov	esi, ecx
	push	edi
	mov	DWORD PTR _this$[esp+32], esi
	mov	DWORD PTR __$EHRec$[esp+40], 1

; 78   : 	Clear();

	call	?Clear@KIpoTree@@QAEXXZ			; KIpoTree::Clear

; 79   : 
; 80   :     if (m_pby_ptpBase)

	mov	eax, DWORD PTR [esi+73836]
	xor	ebp, ebp
	cmp	eax, ebp
	je	SHORT $L90115

; 81   :     {
; 82   :         delete []m_pby_ptpBase;

	push	eax
	call	??3@YAXPAX@Z				; operator delete
	add	esp, 4

; 83   :         m_pby_ptpBase = NULL;

	mov	DWORD PTR [esi+73836], ebp

; 84   :         ptp = NULL;

	mov	DWORD PTR [esi+73832], ebp
$L90115:

; 85   :     }
; 86   : 
; 87   :     if (m_pbyLColorBase)

	mov	eax, DWORD PTR [esi+73828]
	cmp	eax, ebp
	je	SHORT $L90117

; 88   :     {
; 89   :         delete []m_pbyLColorBase;

	push	eax
	call	??3@YAXPAX@Z				; operator delete
	add	esp, 4

; 90   :         m_pbyLColorBase = NULL;

	mov	DWORD PTR [esi+73828], ebp

; 91   : 
; 92   :         pLColor = NULL;

	mov	DWORD PTR [esi+73824], ebp
$L90117:

; 93   :     }
; 94   : }

	mov	ebx, DWORD PTR [esi+92276]
	mov	edi, DWORD PTR [ebx]
	cmp	edi, ebx
	je	SHORT $L91568
$L91567:
	mov	eax, edi
	mov	edi, DWORD PTR [edi]
	push	eax
	mov	ecx, DWORD PTR [eax+4]
	mov	edx, DWORD PTR [eax]
	mov	DWORD PTR [ecx], edx
	mov	ecx, DWORD PTR [eax]
	mov	edx, DWORD PTR [eax+4]
	mov	DWORD PTR [ecx+4], edx
	call	??3@YAXPAX@Z				; operator delete
	mov	ecx, DWORD PTR [esi+92280]
	add	esp, 4
	dec	ecx
	cmp	edi, ebx
	mov	DWORD PTR [esi+92280], ecx
	jne	SHORT $L91567
$L91568:
	mov	eax, DWORD PTR [esi+92276]
	push	eax
	call	??3@YAXPAX@Z				; operator delete
	add	esp, 4
	lea	ecx, DWORD PTR [esi+4]
	mov	DWORD PTR [esi+92276], ebp
	mov	DWORD PTR [esi+92280], ebp
	mov	DWORD PTR __$EHRec$[esp+40], -1
	call	??1KIpotBranch@@QAE@XZ			; KIpotBranch::~KIpotBranch
	mov	ecx, DWORD PTR __$EHRec$[esp+32]
	pop	edi
	pop	esi
	pop	ebp
	pop	ebx
	mov	DWORD PTR fs:__except_list, ecx
	add	esp, 16					; 00000010H
	ret	0
_TEXT	ENDS
;	COMDAT text$x
text$x	SEGMENT
$L91264:
	mov	ecx, DWORD PTR _this$[ebp]
	add	ecx, 4
	jmp	??1KIpotBranch@@QAE@XZ			; KIpotBranch::~KIpotBranch
$L91265:
	mov	ecx, DWORD PTR _this$[ebp]
	add	ecx, 92272				; 00016870H
	jmp	??1?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QAE@XZ ; std::list<KLightBase *,std::allocator<KLightBase *> >::~list<KLightBase *,std::allocator<KLightBase *> >
$L91578:
	mov	eax, OFFSET FLAT:$T91576
	jmp	___CxxFrameHandler
text$x	ENDS
??1KIpoTree@@QAE@XZ ENDP				; KIpoTree::~KIpoTree
PUBLIC	?Paint@KIpoTree@@QAEXPAUtagRECT@@W4IPOT_RENDER_LAYER@@@Z ; KIpoTree::Paint
PUBLIC	?RenderLightMap@KIpoTree@@QAEXXZ		; KIpoTree::RenderLightMap
EXTRN	?PaintObjectLayer@KIpotBranch@@QAEXPAUtagRECT@@@Z:NEAR ; KIpotBranch::PaintObjectLayer
EXTRN	?PaintNoneObjectLayer@KIpotBranch@@QAEXPAUtagRECT@@H@Z:NEAR ; KIpotBranch::PaintNoneObjectLayer
EXTRN	?g_pRepresent@@3PAUiRepresentShell@@A:DWORD	; g_pRepresent
;	COMDAT ?Paint@KIpoTree@@QAEXPAUtagRECT@@W4IPOT_RENDER_LAYER@@@Z
_TEXT	SEGMENT
_pRepresentArea$ = 8
_eLayer$ = 12
?Paint@KIpoTree@@QAEXPAUtagRECT@@W4IPOT_RENDER_LAYER@@@Z PROC NEAR ; KIpoTree::Paint, COMDAT

; 98   : {

	push	esi
	push	edi

; 99   : 	if(eLayer == IPOT_RL_COVER_GROUND && m_bDynamicLighting)

	mov	edi, DWORD PTR _eLayer$[esp+4]
	mov	esi, ecx
	cmp	edi, 1
	jne	SHORT $L90124
	mov	al, BYTE PTR [esi+90]
	test	al, al
	je	SHORT $L90126

; 100  : 	{
; 101  : 		// 渲染光照图
; 102  : 		RenderLightMap();

	call	?RenderLightMap@KIpoTree@@QAEXXZ	; KIpoTree::RenderLightMap

; 103  : 		// 设置表现模块的光照信息
; 104  : 		g_pRepresent->SetLightInfo(m_nLeftTopX, m_nLeftTopY, (unsigned int*)pLightingArray);

	mov	ecx, DWORD PTR ?g_pRepresent@@3PAUiRepresentShell@@A ; g_pRepresent
	lea	edx, DWORD PTR [esi+73840]
	push	edx
	mov	edx, DWORD PTR [esi+80]
	mov	eax, DWORD PTR [ecx]
	push	edx
	mov	edx, DWORD PTR [esi+76]
	push	edx
	call	DWORD PTR [eax+104]
$L90126:

; 113  : 	}
; 114  : 	else if (m_pMainBranch)

	mov	ecx, DWORD PTR [esi]

; 115  : 		m_pMainBranch->PaintNoneObjectLayer(pRepresentArea, eLayer);

	push	edi
	test	ecx, ecx
	je	SHORT $L90130
	mov	edx, DWORD PTR _pRepresentArea$[esp+8]
	push	edx

; 116  : 	else
; 117  : 		m_DefaultBranch.PaintNoneObjectLayer(pRepresentArea, eLayer);

	call	?PaintNoneObjectLayer@KIpotBranch@@QAEXPAUtagRECT@@H@Z ; KIpotBranch::PaintNoneObjectLayer
	pop	edi
	pop	esi

; 118  : }

	ret	8
$L90124:

; 105  : 	}
; 106  : 	
; 107  : 	if (eLayer == IPOT_RL_OBJECT)

	cmp	edi, 2
	jne	SHORT $L90126

; 108  : 	{
; 109  : 		if (m_pMainBranch)

	mov	ecx, DWORD PTR [esi]
	test	ecx, ecx
	je	SHORT $L90127

; 110  : 			m_pMainBranch->PaintObjectLayer(pRepresentArea);

	mov	eax, DWORD PTR _pRepresentArea$[esp+4]
	push	eax
	call	?PaintObjectLayer@KIpotBranch@@QAEXPAUtagRECT@@@Z ; KIpotBranch::PaintObjectLayer
	pop	edi
	pop	esi

; 118  : }

	ret	8
$L90127:

; 111  : 		else
; 112  : 			m_DefaultBranch.PaintObjectLayer(pRepresentArea);

	mov	ecx, DWORD PTR _pRepresentArea$[esp+4]
	push	ecx
	lea	ecx, DWORD PTR [esi+4]
	call	?PaintObjectLayer@KIpotBranch@@QAEXPAUtagRECT@@@Z ; KIpotBranch::PaintObjectLayer
	pop	edi
	pop	esi

; 118  : }

	ret	8
$L90130:

; 116  : 	else
; 117  : 		m_DefaultBranch.PaintNoneObjectLayer(pRepresentArea, eLayer);

	mov	eax, DWORD PTR _pRepresentArea$[esp+8]
	lea	ecx, DWORD PTR [esi+4]
	push	eax
	call	?PaintNoneObjectLayer@KIpotBranch@@QAEXPAUtagRECT@@H@Z ; KIpotBranch::PaintNoneObjectLayer
	pop	edi
	pop	esi

; 118  : }

	ret	8
?Paint@KIpoTree@@QAEXPAUtagRECT@@W4IPOT_RENDER_LAYER@@@Z ENDP ; KIpoTree::Paint
_TEXT	ENDS
PUBLIC	?Breathe@KIpoTree@@QAEXXZ			; KIpoTree::Breathe
;	COMDAT ?Breathe@KIpoTree@@QAEXXZ
_TEXT	SEGMENT
?Breathe@KIpoTree@@QAEXXZ PROC NEAR			; KIpoTree::Breathe, COMDAT

; 121  : {

	push	esi
	push	edi
	mov	edi, ecx

; 122  : 	list<KLightBase*>::iterator i;
; 123  : 	for (i = m_LightList.begin(); i != m_LightList.end(); ++i)

	mov	eax, DWORD PTR [edi+92276]
	mov	esi, DWORD PTR [eax]
	cmp	esi, eax
	je	SHORT $L90141
$L91630:

; 124  : 	{
; 125  : 		if((*i)->m_pParent == NULL)

	mov	ecx, DWORD PTR [esi+8]
	mov	eax, DWORD PTR [ecx+4]
	test	eax, eax
	jne	SHORT $L90140

; 126  : 			(*i)->Breath();

	mov	eax, DWORD PTR [ecx]
	call	DWORD PTR [eax]
$L90140:
	mov	esi, DWORD PTR [esi]
	mov	eax, DWORD PTR [edi+92276]
	cmp	esi, eax
	jne	SHORT $L91630
$L90141:
	pop	edi
	pop	esi

; 127  : 	}
; 128  : }

	ret	0
?Breathe@KIpoTree@@QAEXXZ ENDP				; KIpoTree::Breathe
_TEXT	ENDS
PUBLIC	?RemoveRtoGroupWithPermanentLeaf@KIpoTree@@AAEXXZ ; KIpoTree::RemoveRtoGroupWithPermanentLeaf
EXTRN	?Clear@KIpotBranch@@QAEXXZ:NEAR			; KIpotBranch::Clear
;	COMDAT ?Clear@KIpoTree@@QAEXXZ
_TEXT	SEGMENT
?Clear@KIpoTree@@QAEXXZ PROC NEAR			; KIpoTree::Clear, COMDAT

; 132  : {

	push	ebx
	push	esi
	mov	esi, ecx
	push	edi

; 133  : 	if (m_pMainBranch)

	mov	edi, DWORD PTR [esi]
	test	edi, edi
	je	SHORT $L90146

; 134  : 	{
; 135  : 		delete (m_pMainBranch);

	mov	ecx, edi
	call	??1KIpotBranch@@QAE@XZ			; KIpotBranch::~KIpotBranch
	push	edi
	call	??3@YAXPAX@Z				; operator delete
	add	esp, 4

; 136  : 		m_pMainBranch = NULL;

	mov	DWORD PTR [esi], 0
$L90146:

; 137  : 	}
; 138  : 	m_DefaultBranch.Clear();

	lea	ecx, DWORD PTR [esi+4]
	call	?Clear@KIpotBranch@@QAEXXZ		; KIpotBranch::Clear

; 139  : 	RemoveRtoGroupWithPermanentLeaf();

	mov	ecx, esi
	call	?RemoveRtoGroupWithPermanentLeaf@KIpoTree@@AAEXXZ ; KIpoTree::RemoveRtoGroupWithPermanentLeaf

; 140  : 	
; 141  : 	//clear all dyna light
; 142  : 	list<KLightBase*>::iterator i;
; 143  : 	for (i = m_LightList.begin(); i != m_LightList.end(); ++i)

	mov	eax, DWORD PTR [esi+92276]
	mov	edi, DWORD PTR [eax]
	cmp	edi, eax
	je	SHORT $L90155
$L91725:

; 144  : 	{
; 145  : 		delete (*i);

	mov	eax, DWORD PTR [edi+8]
	push	eax
	call	??3@YAXPAX@Z				; operator delete
	mov	edi, DWORD PTR [edi]
	mov	eax, DWORD PTR [esi+92276]
	add	esp, 4
	cmp	edi, eax
	jne	SHORT $L91725
$L90155:

; 146  : 	}
; 147  : 	m_LightList.clear();

	mov	ebx, DWORD PTR [esi+92276]
	mov	edi, DWORD PTR [ebx]
	cmp	edi, ebx
	je	SHORT $L92008
$L92007:
	mov	eax, edi
	mov	edi, DWORD PTR [edi]
	push	eax
	mov	ecx, DWORD PTR [eax+4]
	mov	edx, DWORD PTR [eax]
	mov	DWORD PTR [ecx], edx
	mov	ecx, DWORD PTR [eax]
	mov	edx, DWORD PTR [eax+4]
	mov	DWORD PTR [ecx+4], edx
	call	??3@YAXPAX@Z				; operator delete
	mov	ecx, DWORD PTR [esi+92280]
	add	esp, 4
	dec	ecx
	cmp	edi, ebx
	mov	DWORD PTR [esi+92280], ecx
	jne	SHORT $L92007
$L92008:
	pop	edi
	pop	esi
	pop	ebx

; 148  : }

	ret	0
?Clear@KIpoTree@@QAEXXZ ENDP				; KIpoTree::Clear
_TEXT	ENDS
;	COMDAT ?RemoveRtoGroupWithPermanentLeaf@KIpoTree@@AAEXXZ
_TEXT	SEGMENT
?RemoveRtoGroupWithPermanentLeaf@KIpoTree@@AAEXXZ PROC NEAR ; KIpoTree::RemoveRtoGroupWithPermanentLeaf, COMDAT

; 152  : 	KIpotRuntimeObj* pRto;
; 153  : 	while(pRto = (KIpotRuntimeObj*)m_PermanentLeaf.pBrother)

	mov	eax, DWORD PTR [ecx+56]
	xor	edx, edx
	cmp	eax, edx
	je	SHORT $L90167
	push	esi
$L90166:

; 154  : 	{
; 155  : 		m_PermanentLeaf.pBrother = pRto->pBrother;

	mov	esi, DWORD PTR [eax+4]
	mov	DWORD PTR [ecx+56], esi

; 156  : 		pRto->pAheadBrother = NULL;

	mov	DWORD PTR [eax+48], edx

; 157  : 		pRto->pBrother = NULL;

	mov	DWORD PTR [eax+4], edx
	mov	eax, DWORD PTR [ecx+56]
	cmp	eax, edx
	jne	SHORT $L90166
	pop	esi
$L90167:

; 158  : 	}
; 159  : }

	ret	0
?RemoveRtoGroupWithPermanentLeaf@KIpoTree@@AAEXXZ ENDP	; KIpoTree::RemoveRtoGroupWithPermanentLeaf
_TEXT	ENDS
PUBLIC	?AddBranch@KIpoTree@@QAEXPAUKIpotBuildinObj@@@Z	; KIpoTree::AddBranch
EXTRN	?AddBranch@KIpotBranch@@QAEXPAUKIpotBuildinObj@@@Z:NEAR ; KIpotBranch::AddBranch
EXTRN	?AddAObject@KIpotBranch@@QAEXPAUKIpotBuildinObj@@@Z:NEAR ; KIpotBranch::AddAObject
;	COMDAT xdata$x
; File D:\Lam game phong than\PhongThanSource\Sources\Core\Src\Scene\KIpoTree.cpp
xdata$x	SEGMENT
$T92076	DD	019930520H
	DD	01H
	DD	FLAT:$T92078
	DD	2 DUP(00H)
	DD	2 DUP(00H)
	ORG $+4
$T92078	DD	0ffffffffH
	DD	FLAT:$L92074
xdata$x	ENDS
;	COMDAT ?AddBranch@KIpoTree@@QAEXPAUKIpotBuildinObj@@@Z
_TEXT	SEGMENT
_pBranchObj$ = 8
$T92071 = 8
__$EHRec$ = -12
?AddBranch@KIpoTree@@QAEXPAUKIpotBuildinObj@@@Z PROC NEAR ; KIpoTree::AddBranch, COMDAT

; 172  : {

	mov	eax, DWORD PTR fs:__except_list
	push	-1
	push	$L92077
	push	eax
	mov	DWORD PTR fs:__except_list, esp
	push	esi
	mov	esi, ecx
	push	edi

; 173  : 	if (m_pMainBranch)

	mov	ecx, DWORD PTR [esi]
	test	ecx, ecx
	je	SHORT $L90173

; 174  : 		m_pMainBranch->AddBranch(pBranchObj);

	mov	eax, DWORD PTR _pBranchObj$[esp+16]
	push	eax
	call	?AddBranch@KIpotBranch@@QAEXPAUKIpotBuildinObj@@@Z ; KIpotBranch::AddBranch

; 179  : 	}
; 180  : }

	mov	ecx, DWORD PTR __$EHRec$[esp+20]
	mov	DWORD PTR fs:__except_list, ecx
	pop	edi
	pop	esi
	add	esp, 12					; 0000000cH
	ret	4
$L90173:

; 175  : 	else if (pBranchObj)

	mov	edi, DWORD PTR _pBranchObj$[esp+16]
	test	edi, edi
	je	SHORT $L90175

; 176  : 	{
; 177  : 		m_pMainBranch = new KIpotBranch;

	push	48					; 00000030H
	call	??2@YAPAXI@Z				; operator new
	add	esp, 4
	mov	DWORD PTR $T92071[esp+16], eax
	test	eax, eax
	mov	DWORD PTR __$EHRec$[esp+28], 0
	je	SHORT $L92072
	mov	ecx, eax
	call	??0KIpotBranch@@QAE@XZ			; KIpotBranch::KIpotBranch
	jmp	SHORT $L92073
$L92072:
	xor	eax, eax
$L92073:

; 178  : 		m_pMainBranch->AddAObject(pBranchObj);

	push	edi
	mov	ecx, eax
	mov	DWORD PTR __$EHRec$[esp+32], -1
	mov	DWORD PTR [esi], eax
	call	?AddAObject@KIpotBranch@@QAEXPAUKIpotBuildinObj@@@Z ; KIpotBranch::AddAObject
$L90175:

; 179  : 	}
; 180  : }

	mov	ecx, DWORD PTR __$EHRec$[esp+20]
	pop	edi
	mov	DWORD PTR fs:__except_list, ecx
	pop	esi
	add	esp, 12					; 0000000cH
	ret	4
_TEXT	ENDS
;	COMDAT text$x
text$x	SEGMENT
$L92074:
	mov	eax, DWORD PTR $T92071[ebp-4]
	push	eax
	call	??3@YAXPAX@Z				; operator delete
	pop	ecx
	ret	0
$L92077:
	mov	eax, OFFSET FLAT:$T92076
	jmp	___CxxFrameHandler
text$x	ENDS
?AddBranch@KIpoTree@@QAEXPAUKIpotBuildinObj@@@Z ENDP	; KIpoTree::AddBranch
PUBLIC	?Fell@KIpoTree@@QAEXXZ				; KIpoTree::Fell
EXTRN	?RemoveAllRtoLeafs@KIpotBranch@@QAEXPAUKIpotLeaf@@@Z:NEAR ; KIpotBranch::RemoveAllRtoLeafs
;	COMDAT ?Fell@KIpoTree@@QAEXXZ
_TEXT	SEGMENT
?Fell@KIpoTree@@QAEXXZ PROC NEAR			; KIpoTree::Fell, COMDAT

; 184  : {

	push	esi
	push	edi
	mov	edi, ecx

; 185  : 	if (m_pMainBranch)

	mov	ecx, DWORD PTR [edi]
	test	ecx, ecx
	je	SHORT $L90183

; 186  : 	{
; 187  : 		m_pMainBranch->RemoveAllRtoLeafs(&m_PermanentLeaf);

	lea	eax, DWORD PTR [edi+52]
	push	eax
	call	?RemoveAllRtoLeafs@KIpotBranch@@QAEXPAUKIpotLeaf@@@Z ; KIpotBranch::RemoveAllRtoLeafs

; 188  : 		delete(m_pMainBranch);

	mov	esi, DWORD PTR [edi]
	test	esi, esi
	je	SHORT $L92086
	mov	ecx, esi
	call	??1KIpotBranch@@QAE@XZ			; KIpotBranch::~KIpotBranch
	push	esi
	call	??3@YAXPAX@Z				; operator delete
	add	esp, 4
$L92086:

; 189  : 		m_pMainBranch = NULL;

	mov	DWORD PTR [edi], 0
$L90183:

; 190  : 	}
; 191  : 	m_DefaultBranch.RemoveAllRtoLeafs(&m_PermanentLeaf);

	lea	ecx, DWORD PTR [edi+52]
	lea	esi, DWORD PTR [edi+4]
	push	ecx
	mov	ecx, esi
	call	?RemoveAllRtoLeafs@KIpotBranch@@QAEXPAUKIpotLeaf@@@Z ; KIpotBranch::RemoveAllRtoLeafs

; 192  : 	m_DefaultBranch.Clear();

	mov	ecx, esi
	call	?Clear@KIpotBranch@@QAEXXZ		; KIpotBranch::Clear

; 193  : 
; 194  : 	//清除所有内建对象的光源
; 195  : 	list<KLightBase*>::iterator i;
; 196  : 	for (i = m_LightList.begin(); i != m_LightList.end(); )

	mov	eax, DWORD PTR [edi+92276]
	mov	esi, DWORD PTR [eax]
	cmp	esi, eax
	je	SHORT $L90192
	push	ebx
$L90191:

; 197  : 	{
; 198  : 		if((*i)->m_pParent == NULL)

	mov	eax, DWORD PTR [esi+8]
	mov	ecx, DWORD PTR [eax+4]
	test	ecx, ecx
	jne	SHORT $L90193

; 199  : 		{
; 200  : 			delete (*i);

	push	eax
	call	??3@YAXPAX@Z				; operator delete

; 201  : 			i = m_LightList.erase(i);

	mov	edx, DWORD PTR [esi+4]
	mov	ebx, DWORD PTR [esi]
	push	esi
	mov	DWORD PTR [edx], ebx
	mov	eax, DWORD PTR [esi]
	mov	ecx, DWORD PTR [esi+4]
	mov	DWORD PTR [eax+4], ecx
	call	??3@YAXPAX@Z				; operator delete
	mov	eax, DWORD PTR [edi+92280]
	add	esp, 8
	dec	eax
	mov	esi, ebx
	mov	DWORD PTR [edi+92280], eax

; 202  : 			continue;

	jmp	SHORT $L92273
$L90193:

; 203  : 		}
; 204  : 		++i;

	mov	esi, DWORD PTR [esi]
$L92273:
	cmp	esi, DWORD PTR [edi+92276]
	jne	SHORT $L90191
	pop	ebx
$L90192:
	pop	edi
	pop	esi

; 205  : 	}
; 206  : }

	ret	0
?Fell@KIpoTree@@QAEXXZ ENDP				; KIpoTree::Fell
_TEXT	ENDS
PUBLIC	?AddLeafLine@KIpoTree@@QAEXPAUKIpotBuildinObj@@@Z ; KIpoTree::AddLeafLine
EXTRN	?AddLeafLine@KIpotBranch@@QAEXPAUKIpotBuildinObj@@@Z:NEAR ; KIpotBranch::AddLeafLine
;	COMDAT ?AddLeafLine@KIpoTree@@QAEXPAUKIpotBuildinObj@@@Z
_TEXT	SEGMENT
_pLeaf$ = 8
?AddLeafLine@KIpoTree@@QAEXPAUKIpotBuildinObj@@@Z PROC NEAR ; KIpoTree::AddLeafLine, COMDAT

; 221  : {

	mov	eax, ecx

; 222  : 	if (m_pMainBranch)

	mov	ecx, DWORD PTR [eax]
	test	ecx, ecx
	je	SHORT $L90200

; 223  : 		m_pMainBranch->AddLeafLine(pLeaf);

	mov	eax, DWORD PTR _pLeaf$[esp-4]
	push	eax

; 224  : 	else
; 225  : 		m_DefaultBranch.AddLeafLine(pLeaf);

	call	?AddLeafLine@KIpotBranch@@QAEXPAUKIpotBuildinObj@@@Z ; KIpotBranch::AddLeafLine

; 226  : }

	ret	4
$L90200:

; 224  : 	else
; 225  : 		m_DefaultBranch.AddLeafLine(pLeaf);

	mov	ecx, DWORD PTR _pLeaf$[esp-4]
	push	ecx
	lea	ecx, DWORD PTR [eax+4]
	call	?AddLeafLine@KIpotBranch@@QAEXPAUKIpotBuildinObj@@@Z ; KIpotBranch::AddLeafLine

; 226  : }

	ret	4
?AddLeafLine@KIpoTree@@QAEXPAUKIpotBuildinObj@@@Z ENDP	; KIpoTree::AddLeafLine
_TEXT	ENDS
PUBLIC	__real@4@3ff6b60b60b60b60b800
PUBLIC	__real@4@4006ff00000000000000
PUBLIC	?Breath@KLightBase@@UAEXXZ			; KLightBase::Breath
PUBLIC	??_7KLightBase@@6B@				; KLightBase::`vftable'
PUBLIC	?AddLeafPoint@KIpoTree@@QAEXPAUKIpotLeaf@@@Z	; KIpoTree::AddLeafPoint
EXTRN	?CoreGetGameObjLightInfo@@YAXIIPAUKLightInfo@@@Z:NEAR ; CoreGetGameObjLightInfo
EXTRN	?Npc@@3PAVKNpc@@A:BYTE				; Npc
EXTRN	?AddLeafPoint@KIpotBranch@@QAEXPAUKIpotLeaf@@@Z:NEAR ; KIpotBranch::AddLeafPoint
EXTRN	?IsPlayer@KNpc@@QAEHXZ:NEAR			; KNpc::IsPlayer
;	COMDAT ??_7KLightBase@@6B@
; File D:\VisualStudio6\VisualStudio6portable-langman.congdongcviet\Microsoft Visual Studio\VC98\INCLUDE\list
CONST	SEGMENT
??_7KLightBase@@6B@ DD FLAT:?Breath@KLightBase@@UAEXXZ	; KLightBase::`vftable'
CONST	ENDS
;	COMDAT __real@4@3ff6b60b60b60b60b800
CONST	SEGMENT
__real@4@3ff6b60b60b60b60b800 DD 03b360b61r	; 0.00277778
CONST	ENDS
;	COMDAT __real@4@4006ff00000000000000
CONST	SEGMENT
__real@4@4006ff00000000000000 DD 0437f0000r	; 255
CONST	ENDS
;	COMDAT ?AddLeafPoint@KIpoTree@@QAEXPAUKIpotLeaf@@@Z
_TEXT	SEGMENT
_pLeaf$ = 8
_lightInfo$90218 = -20
_n$90229 = 8
_color$90236 = -28
?AddLeafPoint@KIpoTree@@QAEXPAUKIpotLeaf@@@Z PROC NEAR	; KIpoTree::AddLeafPoint, COMDAT

; 230  : {

	sub	esp, 28					; 0000001cH
	push	ebx
	mov	ebx, ecx
	push	ebp
	push	esi

; 231  : 	if (m_pMainBranch)

	mov	ecx, DWORD PTR [ebx]
	push	edi

; 232  : 		m_pMainBranch->AddLeafPoint(pLeaf);

	mov	edi, DWORD PTR _pLeaf$[esp+40]
	xor	ebp, ebp
	cmp	ecx, ebp
	push	edi

; 233  : 	else

	jne	SHORT $L92529

; 234  : 		m_DefaultBranch.AddLeafPoint(pLeaf);

	lea	ecx, DWORD PTR [ebx+4]
$L92529:
	call	?AddLeafPoint@KIpotBranch@@QAEXPAUKIpotLeaf@@@Z ; KIpotBranch::AddLeafPoint

; 235  : 	// 
; 236  : 	if (pLeaf->eLeafType == KIpotLeaf::IPOTL_T_RUNTIME_OBJ)

	cmp	DWORD PTR [edi], 1
	jne	$L90240

; 237  : 	{
; 238  : 		KIpotRuntimeObj* pRtoLeaf = (KIpotRuntimeObj*)pLeaf;
; 239  : 		if (pRtoLeaf->eLayerParam & IPOT_RL_LIGHT_PROP)

	test	BYTE PTR [edi+36], 8
	je	$L90240

; 240  : 		{
; 241  : 			// 增加一个光源
; 242  : 			KLightBase *pLight = new KLightBase;

	push	28					; 0000001cH
	call	??2@YAPAXI@Z				; operator new
	mov	esi, eax
	add	esp, 4
	cmp	esi, ebp
	je	$L90240
	mov	DWORD PTR [esi], OFFSET FLAT:??_7KLightBase@@6B@ ; KLightBase::`vftable'

; 243  : 			if(pLight)
; 244  : 			{
; 245  : 				KLightInfo lightInfo;
; 246  : 				CoreGetGameObjLightInfo(pRtoLeaf->uGenre, pRtoLeaf->nId, &lightInfo);

	mov	ecx, DWORD PTR [edi+28]
	mov	edx, DWORD PTR [edi+24]
	lea	eax, DWORD PTR _lightInfo$90218[esp+44]
	push	eax
	push	ecx
	push	edx
	call	?CoreGetGameObjLightInfo@@YAXIIPAUKLightInfo@@@Z ; CoreGetGameObjLightInfo

; 247  : 				pLight->m_dwColor = lightInfo.dwColor;

	mov	eax, DWORD PTR _lightInfo$90218[esp+68]

; 248  : 				pLight->m_oPosition = lightInfo.oPosition;

	mov	edx, DWORD PTR _lightInfo$90218[esp+56]
	lea	ecx, DWORD PTR [esi+8]
	mov	DWORD PTR [esi+20], eax
	mov	eax, DWORD PTR _lightInfo$90218[esp+60]

; 249  : 				pLight->m_nRadius = lightInfo.nRadius;
; 250  : 				pLight->m_pParent = pLeaf;

	mov	DWORD PTR [esi+4], edi
	mov	DWORD PTR [ecx], edx
	mov	edx, DWORD PTR _lightInfo$90218[esp+64]
	add	esp, 12					; 0000000cH
	mov	DWORD PTR [ecx+4], eax
	mov	eax, DWORD PTR _lightInfo$90218[esp+60]
	mov	DWORD PTR [esi+24], eax
	mov	DWORD PTR [ecx+8], edx

; 251  : 				
; 252  : 				switch (pRtoLeaf->uGenre)
; 253  : 				{

	mov	eax, DWORD PTR [edi+24]
	cmp	eax, 5
	jne	$L90228

; 254  : 				case CGOG_NPC:
; 255  : 					if (Npc[pRtoLeaf->nId].IsPlayer())

	mov	eax, DWORD PTR [edi+28]
	lea	ecx, DWORD PTR [eax+eax*2]
	shl	ecx, 6
	sub	ecx, eax
	lea	ecx, DWORD PTR [eax+ecx*8]
	lea	edx, DWORD PTR [ecx+ecx*2]
	lea	eax, DWORD PTR [eax+edx*2]
	lea	ecx, DWORD PTR ?Npc@@3PAVKNpc@@A[eax*4]
	call	?IsPlayer@KNpc@@QAEHXZ			; KNpc::IsPlayer
	test	eax, eax
	je	$L90228

; 256  : 					{
; 257  : 						pLight->m_dwColor = 0xffffffff;

	mov	DWORD PTR [esi+20], -1

; 258  : 						if(m_bIsIndoor)

	mov	al, BYTE PTR [ebx+88]
	test	al, al
	je	SHORT $L90225

; 259  : 						{
; 260  : 							if(m_dwAmbient == 0xff404040)

	mov	ecx, DWORD PTR [ebx+92]
	sub	ecx, -12566464				; ff404040H
	neg	ecx
	sbb	ecx, ecx
	and	ecx, 320				; 00000140H
	mov	DWORD PTR [esi+24], ecx

; 261  : 								pLight->m_nRadius = 0;
; 262  : 							else
; 263  : 								pLight->m_nRadius = MAIN_PLAYER_LIGHT_RADIUS;
; 264  : 						}
; 265  : 						else

	jmp	$L90228
$L90225:

; 266  : 						{
; 267  : 							// 是主角，按时间调整光源亮度
; 268  : 							int n = 0;
; 269  : 							if(m_nCurrentTime >= 480 && m_nCurrentTime <= 960)

	mov	eax, DWORD PTR [ebx+84]
	mov	DWORD PTR _n$90229[esp+40], ebp
	cmp	eax, 480				; 000001e0H
	jl	SHORT $L92531
	cmp	eax, 960				; 000003c0H
	jg	SHORT $L90230

; 270  : 								pLight->m_nRadius = 0;

	mov	DWORD PTR [esi+24], ebp

; 271  : 							else if(m_nCurrentTime < 480)

	jmp	SHORT $L90234
$L90230:
	cmp	eax, 480				; 000001e0H
	jge	SHORT $L90232
$L92531:

; 272  : 							{
; 273  : 								n = 480 - m_nCurrentTime;

	mov	ecx, 480				; 000001e0H
	sub	ecx, eax

; 274  : 								pLight->m_nRadius = MAIN_PLAYER_LIGHT_RADIUS;
; 275  : 							}
; 276  : 							else

	jmp	SHORT $L92532
$L90232:

; 277  : 							{
; 278  : 								n = m_nCurrentTime - 960;

	lea	ecx, DWORD PTR [eax-960]
$L92532:

; 279  : 								pLight->m_nRadius = MAIN_PLAYER_LIGHT_RADIUS;
; 280  : 							}
; 281  : 
; 282  : 							if(n > 360)

	cmp	ecx, 360				; 00000168H
	mov	DWORD PTR _n$90229[esp+40], ecx
	mov	DWORD PTR [esi+24], 320			; 00000140H
	jle	SHORT $L90234

; 283  : 								n = 360;

	mov	DWORD PTR _n$90229[esp+40], 360		; 00000168H
$L90234:

; 284  : 							float f = n / 360.0f;

	fild	DWORD PTR _n$90229[esp+40]
	fmul	DWORD PTR __real@4@3ff6b60b60b60b60b800

; 285  : 							f = f * f;

	fld	ST(0)
	fmulp	ST(1), ST(0)

; 286  : 							KLColor color;
; 287  : 							color.SetColor(pLight->m_dwColor);
; 288  : 							color.Scale(f);

	fmul	DWORD PTR __real@4@4006ff00000000000000
	call	__ftol
	mov	WORD PTR _color$90236[esp+44], ax
	mov	WORD PTR _color$90236[esp+46], ax

; 289  : 							pLight->m_dwColor = color.GetColor();

	mov	edx, DWORD PTR _color$90236[esp+44]
	mov	WORD PTR _color$90236[esp+48], ax
	mov	eax, DWORD PTR _color$90236[esp+46]
	mov	ecx, DWORD PTR _color$90236[esp+48]
	and	edx, 65535				; 0000ffffH
	and	eax, 65535				; 0000ffffH
	or	edx, -256				; ffffff00H
	and	ecx, 65535				; 0000ffffH
	shl	edx, 8
	or	edx, eax
	shl	edx, 8
	or	edx, ecx
	mov	DWORD PTR [esi+20], edx
$L90228:

; 290  : 						}
; 291  : 					}
; 292  : 					break;
; 293  : 				case CGOG_OBJECT:
; 294  : 					break;
; 295  : 				case CGOG_MISSLE:
; 296  : 					//pLight->m_nRadius = MAIN_PLAYER_LIGHT_RADIUS;
; 297  : 					//pLight->m_dwColor = 0xff808080;
; 298  : 					break;
; 299  : 				}
; 300  : 				if(pLight->m_nRadius)

	cmp	DWORD PTR [esi+24], ebp
	je	SHORT $L90239

; 301  :                 {
; 302  : 					m_LightList.push_back(pLight);

	mov	edi, DWORD PTR [ebx+92276]
	push	12					; 0000000cH
	mov	ebp, DWORD PTR [edi+4]
	call	??2@YAPAXI@Z				; operator new
	add	esp, 4
	mov	ecx, edi
	test	edi, edi
	jne	SHORT $L92484
	mov	ecx, eax
$L92484:
	mov	DWORD PTR [eax], ecx
	mov	ecx, ebp
	test	ebp, ebp
	jne	SHORT $L92486
	mov	ecx, eax
$L92486:
	mov	DWORD PTR [eax+4], ecx
	mov	DWORD PTR [edi+4], eax
	mov	edx, DWORD PTR [eax+4]
	mov	DWORD PTR [edx], eax
	add	eax, 8
	test	eax, eax
	je	SHORT $L92511
	mov	DWORD PTR [eax], esi
$L92511:
	mov	eax, DWORD PTR [ebx+92280]
	pop	edi
	inc	eax
	pop	esi
	mov	DWORD PTR [ebx+92280], eax
	pop	ebp
	pop	ebx

; 307  :                     pLight = NULL;
; 308  :                 }
; 309  : 			}
; 310  : 		}
; 311  : 	}
; 312  : }

	add	esp, 28					; 0000001cH
	ret	4
$L90239:

; 303  :                 }
; 304  :                 else
; 305  :                 {
; 306  :                     delete pLight;

	push	esi
	call	??3@YAXPAX@Z				; operator delete
	add	esp, 4
$L90240:
	pop	edi
	pop	esi
	pop	ebp
	pop	ebx

; 307  :                     pLight = NULL;
; 308  :                 }
; 309  : 			}
; 310  : 		}
; 311  : 	}
; 312  : }

	add	esp, 28					; 0000001cH
	ret	4
?AddLeafPoint@KIpoTree@@QAEXPAUKIpotLeaf@@@Z ENDP	; KIpoTree::AddLeafPoint
_TEXT	ENDS
;	COMDAT ?Breath@KLightBase@@UAEXXZ
_TEXT	SEGMENT
?Breath@KLightBase@@UAEXXZ PROC NEAR			; KLightBase::Breath, COMDAT

; 50   : 	virtual void Breath(){}

	ret	0
?Breath@KLightBase@@UAEXXZ ENDP				; KLightBase::Breath
_TEXT	ENDS
PUBLIC	?PluckRto@KIpoTree@@QAEXPAUKIpotRuntimeObj@@@Z	; KIpoTree::PluckRto
EXTRN	?Pluck@KIpotRuntimeObj@@QAEXXZ:NEAR		; KIpotRuntimeObj::Pluck
;	COMDAT ?PluckRto@KIpoTree@@QAEXPAUKIpotRuntimeObj@@@Z
_TEXT	SEGMENT
_pLeaf$ = 8
?PluckRto@KIpoTree@@QAEXPAUKIpotRuntimeObj@@@Z PROC NEAR ; KIpoTree::PluckRto, COMDAT

; 315  : {

	push	ebx

; 316  : 	pLeaf->Pluck();

	mov	ebx, DWORD PTR _pLeaf$[esp]
	push	esi
	push	edi
	mov	edi, ecx
	mov	ecx, ebx
	call	?Pluck@KIpotRuntimeObj@@QAEXXZ		; KIpotRuntimeObj::Pluck

; 317  : 	list<KLightBase*>::iterator i;
; 318  : 	for (i = m_LightList.begin(); i != m_LightList.end(); ++i)

	mov	eax, DWORD PTR [edi+92276]
	mov	esi, DWORD PTR [eax]
	cmp	esi, eax
	je	SHORT $L92717
$L92582:

; 319  : 	{
; 320  : 		if((*i)->m_pParent == pLeaf)

	mov	ecx, DWORD PTR [esi+8]
	cmp	DWORD PTR [ecx+4], ebx
	je	SHORT $L92722
	mov	esi, DWORD PTR [esi]
	cmp	esi, eax
	jne	SHORT $L92582
	pop	edi
	pop	esi
	pop	ebx

; 324  : 			break;
; 325  : 		}
; 326  : 	}
; 327  : }

	ret	4
$L92722:

; 321  : 		{
; 322  : 			delete (*i);

	mov	edx, DWORD PTR [esi+8]
	push	edx
	call	??3@YAXPAX@Z				; operator delete

; 323  : 			m_LightList.erase(i);

	mov	eax, DWORD PTR [esi+4]
	mov	ecx, DWORD PTR [esi]
	push	esi
	mov	DWORD PTR [eax], ecx
	mov	edx, DWORD PTR [esi]
	mov	eax, DWORD PTR [esi+4]
	mov	DWORD PTR [edx+4], eax
	call	??3@YAXPAX@Z				; operator delete
	mov	eax, DWORD PTR [edi+92280]
	add	esp, 8
	dec	eax
	mov	DWORD PTR [edi+92280], eax
$L92717:
	pop	edi
	pop	esi
	pop	ebx

; 324  : 			break;
; 325  : 		}
; 326  : 	}
; 327  : }

	ret	4
?PluckRto@KIpoTree@@QAEXPAUKIpotRuntimeObj@@@Z ENDP	; KIpoTree::PluckRto
_TEXT	ENDS
PUBLIC	?SetPermanentBranchPos@KIpoTree@@QAEXHHH@Z	; KIpoTree::SetPermanentBranchPos
EXTRN	?SetLine@KIpotBranch@@QAEXPAUtagPOINT@@0@Z:NEAR	; KIpotBranch::SetLine
;	COMDAT ?SetPermanentBranchPos@KIpoTree@@QAEXHHH@Z
_TEXT	SEGMENT
_nLeftX$ = 8
_nRightX$ = 12
_y$ = 16
_p1$ = -8
_p2$ = -16
?SetPermanentBranchPos@KIpoTree@@QAEXHHH@Z PROC NEAR	; KIpoTree::SetPermanentBranchPos, COMDAT

; 331  : 	POINT	p1, p2;
; 332  : 	if (nLeftX < nRightX)

	mov	eax, DWORD PTR _nLeftX$[esp-4]
	mov	edx, DWORD PTR _nRightX$[esp-4]
	sub	esp, 16					; 00000010H
	cmp	eax, edx
	jge	SHORT $L92727

; 333  : 	{
; 334  : 		p1.x = nLeftX;

	mov	DWORD PTR _p1$[esp+16], eax

; 335  : 		p2.x = nRightX;
; 336  : 	}
; 337  : 	else if (nLeftX > nRightX)

	jmp	SHORT $L92728
$L92727:
	jle	SHORT $L90266

; 338  : 	{
; 339  : 		p2.x = nLeftX;

	mov	DWORD PTR _p2$[esp+16], eax

; 340  : 		p1.x = nRightX;

	mov	DWORD PTR _p1$[esp+16], edx

; 341  : 	}
; 342  : 	else

	jmp	SHORT $L90267
$L90266:

; 343  : 	{
; 344  : 		p1.x = nLeftX;

	mov	DWORD PTR _p1$[esp+16], eax

; 345  : 		p2.x = nRightX + 2048;

	add	edx, 2048				; 00000800H
$L92728:
	mov	DWORD PTR _p2$[esp+16], edx
$L90267:

; 346  : 	}
; 347  : 	p2.y = p1.y = y;

	mov	eax, DWORD PTR _y$[esp+12]

; 348  : 	m_DefaultBranch.SetLine(&p1, &p2);

	lea	edx, DWORD PTR _p1$[esp+16]
	mov	DWORD PTR _p1$[esp+20], eax
	mov	DWORD PTR _p2$[esp+20], eax
	lea	eax, DWORD PTR _p2$[esp+16]
	add	ecx, 4
	push	eax
	push	edx
	call	?SetLine@KIpotBranch@@QAEXPAUtagPOINT@@0@Z ; KIpotBranch::SetLine

; 349  : }

	add	esp, 16					; 00000010H
	ret	12					; 0000000cH
?SetPermanentBranchPos@KIpoTree@@QAEXHHH@Z ENDP		; KIpoTree::SetPermanentBranchPos
_TEXT	ENDS
PUBLIC	?StrewRtoLeafs@KIpoTree@@QAEXAAUtagRECT@@@Z	; KIpoTree::StrewRtoLeafs
PUBLIC	?ObjectsCallback@KIpoTree@@CAXPAXPAUKIpotLeaf@@@Z ; KIpoTree::ObjectsCallback
EXTRN	?EnumerateObjects@KIpotBranch@@QAEXPAXP6AX0PAUKIpotLeaf@@@Z@Z:NEAR ; KIpotBranch::EnumerateObjects
;	COMDAT ?StrewRtoLeafs@KIpoTree@@QAEXAAUtagRECT@@@Z
_TEXT	SEGMENT
_KeepRtoArea$ = 8
?StrewRtoLeafs@KIpoTree@@QAEXAAUtagRECT@@@Z PROC NEAR	; KIpoTree::StrewRtoLeafs, COMDAT

; 352  : {

	push	ebx
	push	ebp
	push	esi
	mov	esi, ecx

; 353  : 	KIpotBranch* pBranch;
; 354  : 	if (m_pMainBranch)

	xor	ebx, ebx
	mov	eax, DWORD PTR [esi]
	cmp	eax, ebx

; 355  : 		pBranch = m_pMainBranch;

	mov	ebp, eax
	jne	SHORT $L92732

; 356  : 	else
; 357  : 		pBranch = &m_DefaultBranch;

	lea	ebp, DWORD PTR [esi+4]
$L92732:

; 358  : 
; 359  : 	KIpotRuntimeObj* pRto;
; 360  : 	while(pRto = (KIpotRuntimeObj*)m_PermanentLeaf.pBrother)

	mov	eax, DWORD PTR [esi+56]
	cmp	eax, ebx
	je	SHORT $L90278
	push	edi
	mov	edi, DWORD PTR _KeepRtoArea$[esp+12]
$L90277:

; 361  : 	{
; 362  : 		m_PermanentLeaf.pBrother = pRto->pBrother;

	mov	ecx, DWORD PTR [eax+4]
	mov	DWORD PTR [esi+56], ecx

; 363  : 		pRto->pAheadBrother = NULL;
; 364  : 		pRto->pBrother = NULL;
; 365  : 
; 366  : 		if (pRto->oPosition.x >= KeepRtoArea.left  ||
; 367  : 			pRto->oPosition.x <  KeepRtoArea.right ||
; 368  : 			pRto->oPosition.y >= KeepRtoArea.top   ||
; 369  : 			pRto->oPosition.y <  KeepRtoArea.bottom)

	mov	ecx, DWORD PTR [eax+16]
	mov	DWORD PTR [eax+48], ebx
	mov	DWORD PTR [eax+4], ebx
	cmp	ecx, DWORD PTR [edi]
	jge	SHORT $L90281
	cmp	ecx, DWORD PTR [edi+8]
	jl	SHORT $L90281
	mov	ecx, DWORD PTR [eax+20]
	mov	edx, DWORD PTR [edi+4]
	cmp	ecx, edx
	jge	SHORT $L90281
	cmp	ecx, DWORD PTR [edi+12]
	jl	SHORT $L90281

; 372  : 		}
; 373  : 		else
; 374  : 		{
; 375  : 			PluckRto(pRto);				

	push	eax
	mov	ecx, esi
	call	?PluckRto@KIpoTree@@QAEXPAUKIpotRuntimeObj@@@Z ; KIpoTree::PluckRto
	jmp	SHORT $L90282
$L90281:

; 370  : 		{
; 371  : 			pBranch->AddLeafPoint(pRto);

	push	eax
	mov	ecx, ebp
	call	?AddLeafPoint@KIpotBranch@@QAEXPAUKIpotLeaf@@@Z ; KIpotBranch::AddLeafPoint
$L90282:
	mov	eax, DWORD PTR [esi+56]
	cmp	eax, ebx
	jne	SHORT $L90277
	pop	edi
$L90278:

; 376  : 		}
; 377  : 	}
; 378  : 
; 379  : 	if(m_bDynamicLighting)

	cmp	BYTE PTR [esi+90], bl
	je	SHORT $L90289

; 380  : 	{
; 381  : 		// 清空遮挡信息
; 382  : 		for(int j=0; j<LIGHTING_GRID_WIDTH*LIGHTING_GRID_HEIGHT; j++)

	lea	eax, DWORD PTR [esi+96]
	mov	ecx, 4608				; 00001200H
$L90285:

; 383  : 		{
; 384  : 			pObstacle[j].nObstacle = 0;

	mov	DWORD PTR [eax], ebx
	add	eax, 16					; 00000010H
	dec	ecx
	jne	SHORT $L90285

; 385  : 		}
; 386  : 
; 387  : 		// 遍历树，计算遮挡信息
; 388  : 		if (m_pMainBranch)

	mov	ecx, DWORD PTR [esi]

; 389  : 			m_pMainBranch->EnumerateObjects(this, ObjectsCallback);

	push	OFFSET FLAT:?ObjectsCallback@KIpoTree@@CAXPAXPAUKIpotLeaf@@@Z ; KIpoTree::ObjectsCallback
	cmp	ecx, ebx
	push	esi

; 390  : 		else

	jne	SHORT $L92735

; 391  : 			m_DefaultBranch.EnumerateObjects(this, ObjectsCallback);

	lea	ecx, DWORD PTR [esi+4]
$L92735:
	call	?EnumerateObjects@KIpotBranch@@QAEXPAXP6AX0PAUKIpotLeaf@@@Z@Z ; KIpotBranch::EnumerateObjects
$L90289:
	pop	esi
	pop	ebp
	pop	ebx

; 392  : 	}
; 393  : }

	ret	4
?StrewRtoLeafs@KIpoTree@@QAEXAAUtagRECT@@@Z ENDP	; KIpoTree::StrewRtoLeafs
_TEXT	ENDS
PUBLIC	?FillLineObstacle@KIpoTree@@AAEXHHHHH@Z		; KIpoTree::FillLineObstacle
;	COMDAT ?ObjectsCallback@KIpoTree@@CAXPAXPAUKIpotLeaf@@@Z
_TEXT	SEGMENT
_p$ = 8
_pLeaf$ = 12
?ObjectsCallback@KIpoTree@@CAXPAXPAUKIpotLeaf@@@Z PROC NEAR ; KIpoTree::ObjectsCallback, COMDAT

; 398  : 	_ASSERT(p);
; 399  : 	_ASSERT(pLeaf);
; 400  : 	static int nObstacleID = 1;
; 401  : 	nObstacleID++;
; 402  : 
; 403  : 	if(pLeaf->eLeafType == KIpotLeaf::IPOTL_T_RUNTIME_OBJ)

	mov	eax, DWORD PTR _pLeaf$[esp-4]
	push	ebx
	push	ebp
	mov	ebp, DWORD PTR _?nObstacleID@?1??ObjectsCallback@KIpoTree@@CAXPAXPAUKIpotLeaf@@@Z@4HA
	inc	ebp
	push	esi
	mov	DWORD PTR _?nObstacleID@?1??ObjectsCallback@KIpoTree@@CAXPAXPAUKIpotLeaf@@@Z@4HA, ebp
	mov	ecx, DWORD PTR [eax]
	cmp	ecx, 1
	push	edi
	je	$L90313

; 404  : 		return;
; 405  : 
; 406  : 	KIpoTree *pTree = (KIpoTree*)p;
; 407  : 	KIpotBuildinObj* pObj = (KIpotBuildinObj*)pLeaf;
; 408  : 	KBuildinObj* pBio = ((KIpotBuildinObj*)pLeaf)->pBio;

	mov	ecx, DWORD PTR [eax+48]

; 409  : 	if((pBio->Props & SPBIO_P_BLOCK_LIGHT_MASK) == SPBIO_P_BLOCK_LIGHT_NONE)

	mov	ecx, DWORD PTR [ecx]
	and	ecx, 48					; 00000030H
	je	$L90313

; 410  : 		return;
; 411  : 
; 412  : 	if((pBio->Props & SPBIO_P_BLOCK_LIGHT_MASK) == SPBIO_P_BLOCK_LIGHT_BOTTOM)

	cmp	ecx, 16					; 00000010H
	jne	SHORT $L90306

; 413  : 	{
; 414  : 		// 按线段处理遮挡
; 415  : 		pTree->FillLineObstacle(pObj->oPosition.x - pTree->m_nLeftTopX, pObj->oPosition.y - pTree->m_nLeftTopY, 
; 416  : 								pObj->oEndPos.x - pTree->m_nLeftTopX, pObj->oEndPos.y - pTree->m_nLeftTopY, nObstacleID);

	mov	ecx, DWORD PTR _p$[esp+12]
	mov	edi, DWORD PTR [eax+32]
	push	ebp
	mov	edx, DWORD PTR [ecx+80]
	mov	esi, DWORD PTR [ecx+76]
	sub	edi, edx
	push	edi
	mov	edi, DWORD PTR [eax+28]
	sub	edi, esi
	push	edi
	mov	edi, DWORD PTR [eax+20]
	mov	eax, DWORD PTR [eax+16]
	sub	edi, edx
	sub	eax, esi
	push	edi
	push	eax
	call	?FillLineObstacle@KIpoTree@@AAEXHHHHH@Z	; KIpoTree::FillLineObstacle
	pop	edi
	pop	esi
	pop	ebp
	pop	ebx

; 435  : 		}
; 436  : 	}
; 437  : }

	ret	0
$L90306:

; 417  : 	}
; 418  : 	else if((pBio->Props & SPBIO_P_BLOCK_LIGHT_MASK) == SPBIO_P_BLOCK_LIGHT_CIRCLE)

	cmp	ecx, 32					; 00000020H
	jne	SHORT $L90313

; 419  : 	{
; 420  : 		// 按圆处理光线遮挡，忽略半径，都按一个格子处理
; 421  : 		int nX = pObj->oPosition.x;
; 422  : 		int nY = pObj->oPosition.y;
; 423  : 		int nIdx;
; 424  : 		if(nX < pTree->m_nLeftTopX || nY < pTree->m_nLeftTopY ||
; 425  : 				nX >= pTree->m_nLeftTopX + AREGION_WIDTH * 3 || nY >= pTree->m_nLeftTopY + AREGION_HEIGHT * 3)

	mov	esi, DWORD PTR _p$[esp+12]
	mov	edi, DWORD PTR [eax+16]
	mov	eax, DWORD PTR [eax+20]
	mov	ebx, DWORD PTR [esi+76]
	cmp	edi, ebx
	jl	SHORT $L90313
	mov	ecx, DWORD PTR [esi+80]
	cmp	eax, ecx
	jl	SHORT $L90313
	lea	edx, DWORD PTR [ebx+1536]
	cmp	edi, edx
	jge	SHORT $L90313
	lea	edx, DWORD PTR [ecx+3072]
	cmp	eax, edx
	jge	SHORT $L90313

; 426  : 			return;
; 427  : 		else
; 428  : 		{
; 429  : 			nX = (nX - pTree->m_nLeftTopX) / LIGHTING_GRID_SIZEX;
; 430  : 			nY = (nY - pTree->m_nLeftTopY) / LIGHTING_GRID_SIZEY;

	sub	eax, ecx
	cdq
	and	edx, 31					; 0000001fH
	add	eax, edx
	sar	eax, 5

; 431  : 			nIdx = nY * LIGHTING_GRID_WIDTH + nX;

	lea	ecx, DWORD PTR [eax+eax*2]
	mov	eax, edi
	sub	eax, ebx
	cdq
	and	edx, 31					; 0000001fH
	add	eax, edx
	shl	ecx, 4
	sar	eax, 5
	add	ecx, eax

; 432  : 			pTree->pObstacle[nIdx].nObstacle = nObstacleID;

	lea	eax, DWORD PTR [ecx+6]
	shl	eax, 4

; 433  : 			// 将方向的x分量设为0，表示不考虑方向
; 434  : 			pTree->pObstacle[nIdx].vDir.fX = 0.0f;

	shl	ecx, 4
	mov	DWORD PTR [eax+esi], ebp
	mov	DWORD PTR [ecx+esi+100], 0
$L90313:
	pop	edi
	pop	esi
	pop	ebp
	pop	ebx

; 435  : 		}
; 436  : 	}
; 437  : }

	ret	0
?ObjectsCallback@KIpoTree@@CAXPAXPAUKIpotLeaf@@@Z ENDP	; KIpoTree::ObjectsCallback
_TEXT	ENDS
PUBLIC	__real@4@40048000000000000000
PUBLIC	__real@4@c0048000000000000000
;	COMDAT __real@4@40048000000000000000
; File D:\Lam game phong than\PhongThanSource\Sources\Core\Src\Scene\KIpoTree.cpp
CONST	SEGMENT
__real@4@40048000000000000000 DD 042000000r	; 32
CONST	ENDS
;	COMDAT __real@4@c0048000000000000000
CONST	SEGMENT
__real@4@c0048000000000000000 DD 0c2000000r	; -32
CONST	ENDS
;	COMDAT ?FillLineObstacle@KIpoTree@@AAEXHHHHH@Z
_TEXT	SEGMENT
_x1$ = 8
_y1$ = 12
_x2$ = 16
_y2$ = 20
_nObstacleID$ = 24
_fy1$ = 12
_fdx$ = 8
_fdy$ = -36
_gStepX$ = 16
_gStepY$ = 12
_gx1$ = -28
_gy1$ = -20
_gx2$ = -16
_gy2$ = -12
_vDir$ = -8
_fFlope1$ = -24
?FillLineObstacle@KIpoTree@@AAEXHHHHH@Z PROC NEAR	; KIpoTree::FillLineObstacle, COMDAT

; 440  : {

	sub	esp, 36					; 00000024H
	push	ebx

; 441  : 	if(x1 >= x2)

	mov	ebx, DWORD PTR _x2$[esp+36]
	push	ebp
	mov	ebp, DWORD PTR _x1$[esp+40]
	push	esi
	cmp	ebp, ebx
	push	edi
	mov	esi, ecx
	jge	$L90391

; 442  : 		return;
; 443  : 
; 444  : 	float fx1, fy1, fx2, fy2, fdx, fdy, fStepX, fStepY;
; 445  : 	int gStepX, gStepY, gx, gy, nIdx, gx1, gy1, gx2, gy2;
; 446  : 	fx1 = (float)x1, fy1 = (float)y1, fx2 = (float)x2, fy2 = (float)y2;

	fild	DWORD PTR _x1$[esp+48]
	fild	DWORD PTR _y1$[esp+48]

; 447  : 	fdx = (float)fabs(fx2 - fx1);

	fild	DWORD PTR _x2$[esp+48]
	fsub	ST(0), ST(2)
	fabs
	fstp	DWORD PTR _fdx$[esp+48]

; 448  : 	fdy = (float)fabs(fy2 - fy1);

	fild	DWORD PTR _y2$[esp+48]

; 449  : 	KVector2 vDir;
; 450  : 	vDir.fX = fdx;

	mov	eax, DWORD PTR _fdx$[esp+48]
	mov	DWORD PTR _vDir$[esp+52], eax

; 451  : 	vDir.fY = fdy;
; 452  : 	float fFlope1, fFlope2;
; 453  : 	gx1 = x1 / LIGHTING_GRID_SIZEX;

	mov	eax, ebp
	fsub	ST(0), ST(1)
	cdq
	fabs
	fstp	DWORD PTR _fdy$[esp+52]

; 454  : 	gy1 = y1 / LIGHTING_GRID_SIZEX;
; 455  : 	gx2 = x2 / LIGHTING_GRID_SIZEX;
; 456  : 	gy2 = y2 / LIGHTING_GRID_SIZEX;
; 457  : 
; 458  : 	fFlope1 = fdy / fdx;

	fld	DWORD PTR _fdy$[esp+52]
	fdiv	DWORD PTR _fdx$[esp+48]
	and	edx, 31					; 0000001fH
	mov	ecx, DWORD PTR _fdy$[esp+52]
	add	eax, edx
	mov	DWORD PTR _vDir$[esp+56], ecx
	mov	edi, eax
	mov	eax, DWORD PTR _y1$[esp+48]
	cdq
	and	edx, 31					; 0000001fH
	add	eax, edx
	mov	ecx, eax
	mov	eax, ebx
	cdq
	and	edx, 31					; 0000001fH
	add	eax, edx
	mov	ebx, eax
	mov	eax, DWORD PTR _y2$[esp+48]
	cdq
	and	edx, 31					; 0000001fH
	add	edx, eax
	sar	edi, 5
	sar	ecx, 5
	sar	ebx, 5
	sar	edx, 5
	mov	DWORD PTR _gx1$[esp+52], edi
	mov	DWORD PTR _gy1$[esp+52], ecx
	mov	DWORD PTR _gx2$[esp+52], ebx
	mov	DWORD PTR _gy2$[esp+52], edx
	fstp	DWORD PTR -32+[esp+52]

; 459  : 
; 460  : 	// 斜率小于45度的情况
; 461  : 	if(fdx >= fdy)

	fld	DWORD PTR _fdx$[esp+48]
	fcomp	DWORD PTR _fdy$[esp+52]
	mov	eax, DWORD PTR -32+[esp+52]
	mov	DWORD PTR _fFlope1$[esp+52], eax
	fnstsw	ax
	test	ah, 1
	jne	$L90350

; 462  : 	{
; 463  : 		if(gx1 == gx2)

	cmp	edi, ebx
	je	$L92754

; 464  : 			return;
; 465  : 
; 466  : 		if(x2 > x1)

	mov	edx, DWORD PTR _x2$[esp+48]
	or	eax, -1
	cmp	edx, ebp
	mov	ecx, 1
	jle	SHORT $L90352

; 467  : 		{
; 468  : 			gStepX = 1;
; 469  : 			fStepX = LIGHTING_GRID_SIZEX;

	fld	DWORD PTR __real@4@40048000000000000000
	mov	DWORD PTR _gStepX$[esp+48], ecx

; 470  : 		}
; 471  : 		else

	jmp	SHORT $L90353
$L90352:

; 472  : 		{
; 473  : 			gStepX = -1;
; 474  : 			fStepX = -LIGHTING_GRID_SIZEX;

	fld	DWORD PTR __real@4@c0048000000000000000
	mov	DWORD PTR _gStepX$[esp+48], eax
$L90353:

; 475  : 		}
; 476  : 		if(y2 > y1)

	mov	edx, DWORD PTR _y1$[esp+48]
	mov	edi, DWORD PTR _y2$[esp+48]
	cmp	edi, edx
	jle	SHORT $L90354

; 477  : 		{
; 478  : 			gStepY = 1;
; 479  : 			fStepY = fdy / fdx * LIGHTING_GRID_SIZEX;

	fld	DWORD PTR -32+[esp+52]
	fmul	DWORD PTR __real@4@40048000000000000000
	mov	DWORD PTR _gStepY$[esp+48], ecx

; 480  : 		}
; 481  : 		else

	jmp	SHORT $L92752
$L90354:

; 482  : 		{
; 483  : 			gStepY = -1;
; 484  : 			fStepY = -fdy / fdx * LIGHTING_GRID_SIZEX;

	fld	DWORD PTR -32+[esp+52]
	fmul	DWORD PTR __real@4@c0048000000000000000
	mov	DWORD PTR _gStepY$[esp+48], eax
$L92752:
	mov	ebx, DWORD PTR _nObstacleID$[esp+48]
	mov	ebp, DWORD PTR _vDir$[esp+52]
$L90357:

; 485  : 		}
; 486  : 		while(1)
; 487  : 		{
; 488  : 			int nx = (int)fx1;
; 489  : 			int ny = (int)fy1;
; 490  : 
; 491  : 			gx = nx / LIGHTING_GRID_SIZEX;

	fld	ST(3)
	call	__ftol
	cdq

; 492  : 			gy = ny / LIGHTING_GRID_SIZEX;

	fld	ST(2)
	and	edx, 31					; 0000001fH
	add	eax, edx
	mov	edi, eax
	sar	edi, 5
	call	__ftol
	cdq
	and	edx, 31					; 0000001fH
	add	eax, edx
	sar	eax, 5

; 493  : 
; 494  : 			if(gx >0 && gx < LIGHTING_GRID_WIDTH - 1 && gy >0 && gy < LIGHTING_GRID_HEIGHT - 1)

	test	edi, edi
	jle	$L90366
	cmp	edi, 47					; 0000002fH
	jge	$L90366
	test	eax, eax
	jle	$L90366
	cmp	eax, 95					; 0000005fH
	jge	$L90366

; 495  : 			{
; 496  : 				nIdx = gy * LIGHTING_GRID_WIDTH + gx;

	lea	ecx, DWORD PTR [eax+eax*2]
	shl	ecx, 4
	add	ecx, edi

; 497  : 				pObstacle[nIdx].nObstacle = nObstacleID;

	lea	edx, DWORD PTR [ecx+6]
	shl	edx, 4
	mov	DWORD PTR [edx+esi], ebx

; 498  : 				pObstacle[nIdx].vDir = vDir;

	mov	edx, ecx
	shl	edx, 4
	mov	DWORD PTR [edx+esi+100], ebp
	mov	ebp, DWORD PTR _vDir$[esp+56]
	mov	DWORD PTR [edx+esi+104], ebp

; 499  : 
; 500  : 				fFlope2 = (float)(fabs((gy + gStepY) * 32.0f - fy1) / fabs((gx + gStepX) * 32.0f - fx1));

	mov	edx, DWORD PTR _gStepY$[esp+48]
	add	edx, eax
	mov	ebp, DWORD PTR _gStepX$[esp+48]
	mov	DWORD PTR 20+[esp+48], edx

; 501  : 				if(fFlope2 > fFlope1)

	fild	DWORD PTR 20+[esp+48]
	lea	eax, DWORD PTR [edi+ebp]
	mov	DWORD PTR 20+[esp+48], eax
	fmul	DWORD PTR __real@4@40048000000000000000
	fsub	ST(0), ST(3)
	fabs
	fild	DWORD PTR 20+[esp+48]
	fmul	DWORD PTR __real@4@40048000000000000000
	fsub	ST(0), ST(5)
	fabs
	fdivp	ST(1), ST(0)
	fcomp	DWORD PTR _fFlope1$[esp+52]
	fnstsw	ax
	test	ah, 65					; 00000041H
	jne	SHORT $L90365

; 502  : 				{
; 503  : 					nIdx = (gy + gStepY) * LIGHTING_GRID_WIDTH + gx;

	lea	eax, DWORD PTR [edx+edx*2]
	shl	eax, 4
	add	eax, edi

; 504  : 					pObstacle[nIdx].nObstacle = nObstacleID;
; 505  : 					pObstacle[nIdx].vDir = vDir;
; 506  : 				}
; 507  : 				else

	jmp	SHORT $L92758
$L90365:

; 508  : 				{
; 509  : 					nIdx = gy * LIGHTING_GRID_WIDTH + gx + gStepX;

	lea	eax, DWORD PTR [ecx+ebp]
$L92758:

; 510  : 					pObstacle[nIdx].nObstacle = nObstacleID;
; 511  : 					pObstacle[nIdx].vDir = vDir;

	mov	ebp, DWORD PTR _vDir$[esp+52]
	mov	edx, DWORD PTR _vDir$[esp+56]
	lea	ecx, DWORD PTR [eax+6]
	shl	ecx, 4
	shl	eax, 4
	mov	DWORD PTR [ecx+esi], ebx
	mov	DWORD PTR [eax+esi+100], ebp
	mov	DWORD PTR [eax+esi+104], edx
$L90366:

; 517  : 			gx1 += gStepX;

	mov	eax, DWORD PTR _gx1$[esp+52]
	mov	edx, DWORD PTR _gStepX$[esp+48]

; 518  : 			if(gx1 == gx2)

	mov	ecx, DWORD PTR _gx2$[esp+52]
	add	eax, edx
	fld	ST(1)
	faddp	ST(4), ST(0)
	cmp	eax, ecx
	mov	DWORD PTR _gx1$[esp+52], eax
	fld	ST(0)
	faddp	ST(3), ST(0)
	jne	$L90357

; 522  : 				if(gx >0 && gx < LIGHTING_GRID_WIDTH - 1 && gy >0 && gy < LIGHTING_GRID_HEIGHT - 1)
; 523  : 				{
; 524  : 					nIdx = gy * LIGHTING_GRID_WIDTH + gx;
; 525  : 					pObstacle[nIdx].nObstacle = nObstacleID;
; 526  : 					pObstacle[nIdx].vDir = vDir;
; 527  : 				}
; 528  : 				return;

	jmp	$L92760
$L90350:

; 529  : 			}
; 530  : 		}
; 531  : 	}
; 532  : 	// 斜率大于45度的情况
; 533  : 	else
; 534  : 	{
; 535  : 		if(gy1 == gy2)

	cmp	ecx, edx
	je	$L92754

; 536  : 			return;
; 537  : 
; 538  : 		if(y2 > y1)

	mov	edx, DWORD PTR _y1$[esp+48]
	mov	edi, DWORD PTR _y2$[esp+48]
	or	eax, -1
	cmp	edi, edx
	mov	ecx, 1
	jle	SHORT $L90373

; 539  : 		{
; 540  : 			gStepY = 1;
; 541  : 			fStepY = LIGHTING_GRID_SIZEX;

	fld	DWORD PTR __real@4@40048000000000000000
	mov	DWORD PTR _gStepY$[esp+48], ecx

; 542  : 		}
; 543  : 		else

	jmp	SHORT $L90374
$L90373:

; 544  : 		{
; 545  : 			gStepY = -1;
; 546  : 			fStepY = -LIGHTING_GRID_SIZEX;

	fld	DWORD PTR __real@4@c0048000000000000000
	mov	DWORD PTR _gStepY$[esp+48], eax
$L90374:

; 547  : 		}
; 548  : 		if(x2 > x1)

	cmp	DWORD PTR _x2$[esp+48], ebp
	jle	SHORT $L90375

; 549  : 		{
; 550  : 			gStepX = 1;
; 551  : 			fStepX = fdx / fdy * LIGHTING_GRID_SIZEX;

	fld	DWORD PTR _fdx$[esp+48]
	fdiv	DWORD PTR _fdy$[esp+52]
	mov	DWORD PTR _gStepX$[esp+48], ecx
	fmul	DWORD PTR __real@4@40048000000000000000

; 552  : 		}
; 553  : 		else

	jmp	SHORT $L92753
$L90375:

; 554  : 		{
; 555  : 			gStepX = -1;
; 556  : 			fStepX = -fdx / fdy * LIGHTING_GRID_SIZEX;

	fld	DWORD PTR _fdx$[esp+48]
	fdiv	DWORD PTR _fdy$[esp+52]
	mov	DWORD PTR _gStepX$[esp+48], eax
	fmul	DWORD PTR __real@4@c0048000000000000000
$L92753:
	mov	ebx, DWORD PTR _nObstacleID$[esp+48]
	mov	ebp, DWORD PTR _vDir$[esp+52]
$L90378:

; 557  : 		}
; 558  : 		while(1)
; 559  : 		{
; 560  : 			int nx = (int)fx1;
; 561  : 			int ny = (int)fy1;
; 562  : 
; 563  : 			gx = nx / LIGHTING_GRID_SIZEX;

	fld	ST(3)
	call	__ftol
	cdq

; 564  : 			gy = ny / LIGHTING_GRID_SIZEX;

	fld	ST(2)
	and	edx, 31					; 0000001fH
	add	eax, edx
	mov	edi, eax
	sar	edi, 5
	call	__ftol
	cdq
	and	edx, 31					; 0000001fH
	add	eax, edx
	sar	eax, 5

; 565  : 
; 566  : 			if(gx >0 && gx < LIGHTING_GRID_WIDTH - 1 && gy >0 && gy < LIGHTING_GRID_HEIGHT - 1)

	test	edi, edi
	jle	$L90387
	cmp	edi, 47					; 0000002fH
	jge	$L90387
	test	eax, eax
	jle	$L90387
	cmp	eax, 95					; 0000005fH
	jge	$L90387

; 567  : 			{
; 568  : 				nIdx = gy * LIGHTING_GRID_WIDTH + gx;

	lea	ecx, DWORD PTR [eax+eax*2]
	shl	ecx, 4
	add	ecx, edi

; 569  : 				pObstacle[nIdx].nObstacle = nObstacleID;

	lea	edx, DWORD PTR [ecx+6]
	shl	edx, 4
	mov	DWORD PTR [edx+esi], ebx

; 570  : 				pObstacle[nIdx].vDir = vDir;

	mov	edx, ecx
	shl	edx, 4
	mov	DWORD PTR [edx+esi+100], ebp
	mov	ebp, DWORD PTR _vDir$[esp+56]
	mov	DWORD PTR [edx+esi+104], ebp

; 571  : 
; 572  : 				fFlope2 = (float)(fabs((gy + gStepY) * 32.0f - fy1) / fabs((gx + gStepX) * 32.0f - fx1));

	mov	edx, DWORD PTR _gStepY$[esp+48]
	add	edx, eax
	mov	ebp, DWORD PTR _gStepX$[esp+48]
	mov	DWORD PTR 20+[esp+48], edx

; 573  : 				if(fFlope2 > fFlope1)

	fild	DWORD PTR 20+[esp+48]
	lea	eax, DWORD PTR [edi+ebp]
	mov	DWORD PTR 20+[esp+48], eax
	fmul	DWORD PTR __real@4@40048000000000000000
	fsub	ST(0), ST(3)
	fabs
	fild	DWORD PTR 20+[esp+48]
	fmul	DWORD PTR __real@4@40048000000000000000
	fsub	ST(0), ST(5)
	fabs
	fdivp	ST(1), ST(0)
	fcomp	DWORD PTR _fFlope1$[esp+52]
	fnstsw	ax
	test	ah, 65					; 00000041H
	jne	SHORT $L90386

; 574  : 				{
; 575  : 					nIdx = (gy + gStepY) * LIGHTING_GRID_WIDTH + gx;

	lea	eax, DWORD PTR [edx+edx*2]
	shl	eax, 4
	add	eax, edi

; 576  : 					pObstacle[nIdx].nObstacle = nObstacleID;
; 577  : 					pObstacle[nIdx].vDir = vDir;
; 578  : 				}
; 579  : 				else

	jmp	SHORT $L92759
$L90386:

; 580  : 				{
; 581  : 					nIdx = gy * LIGHTING_GRID_WIDTH + gx + gStepX;

	lea	eax, DWORD PTR [ecx+ebp]
$L92759:

; 582  : 					pObstacle[nIdx].nObstacle = nObstacleID;
; 583  : 					pObstacle[nIdx].vDir = vDir;

	mov	ebp, DWORD PTR _vDir$[esp+52]
	mov	edx, DWORD PTR _vDir$[esp+56]
	lea	ecx, DWORD PTR [eax+6]
	shl	ecx, 4
	shl	eax, 4
	mov	DWORD PTR [ecx+esi], ebx
	mov	DWORD PTR [eax+esi+100], ebp
	mov	DWORD PTR [eax+esi+104], edx
$L90387:

; 589  : 			gy1 += gStepY;

	mov	eax, DWORD PTR _gy1$[esp+52]
	mov	edx, DWORD PTR _gStepY$[esp+48]

; 590  : 			if(gy1 == gy2)

	mov	ecx, DWORD PTR _gy2$[esp+52]
	add	eax, edx
	fld	ST(0)
	faddp	ST(4), ST(0)
	fld	ST(1)
	cmp	eax, ecx
	mov	DWORD PTR _gy1$[esp+52], eax
	faddp	ST(3), ST(0)
	jne	$L90378
$L92760:

; 584  : 				}
; 585  : 			}
; 586  : 
; 587  : 			fx1 += fStepX;
; 588  : 			fy1 += fStepY;

	fstp	ST(0)
	fstp	ST(0)
	fstp	DWORD PTR _fy1$[esp+48]

; 591  : 			{
; 592  : 				gx = ((int)fx1) / LIGHTING_GRID_SIZEX;

	call	__ftol
	cdq

; 593  : 				gy = ((int)fy1) / LIGHTING_GRID_SIZEX;

	fld	DWORD PTR _fy1$[esp+48]
	and	edx, 31					; 0000001fH
	add	eax, edx
	mov	edi, eax
	sar	edi, 5
	call	__ftol
	cdq
	and	edx, 31					; 0000001fH
	add	eax, edx
	sar	eax, 5

; 594  : 				if(gx >0 && gx < LIGHTING_GRID_WIDTH - 1 && gy >0 && gy < LIGHTING_GRID_HEIGHT - 1)

	test	edi, edi
	jle	SHORT $L90391
	cmp	edi, 47					; 0000002fH
	jge	SHORT $L90391
	test	eax, eax
	jle	SHORT $L90391
	cmp	eax, 95					; 0000005fH
	jge	SHORT $L90391

; 595  : 				{
; 596  : 					nIdx = gy * LIGHTING_GRID_WIDTH + gx;

	lea	eax, DWORD PTR [eax+eax*2]

; 597  : 					pObstacle[nIdx].nObstacle = nObstacleID;
; 598  : 					pObstacle[nIdx].vDir = vDir;

	mov	edx, DWORD PTR _vDir$[esp+56]
	shl	eax, 4
	add	eax, edi
	pop	edi
	lea	ecx, DWORD PTR [eax+6]
	shl	ecx, 4
	shl	eax, 4
	mov	DWORD PTR [ecx+esi], ebx
	mov	DWORD PTR [eax+esi+100], ebp
	mov	DWORD PTR [eax+esi+104], edx
	pop	esi
	pop	ebp
	pop	ebx

; 599  : 				}
; 600  : 				return;
; 601  : 			}
; 602  : 		}
; 603  : 	}
; 604  : }

	add	esp, 36					; 00000024H
	ret	20					; 00000014H
$L92754:

; 512  : 				}
; 513  : 			}
; 514  : 
; 515  : 			fx1 += fStepX;
; 516  : 			fy1 += fStepY;

	fstp	ST(0)

; 519  : 			{
; 520  : 				gx = ((int)fx1) / LIGHTING_GRID_SIZEX;
; 521  : 				gy = ((int)fy1) / LIGHTING_GRID_SIZEX;

	fstp	ST(0)
$L90391:
	pop	edi
	pop	esi
	pop	ebp
	pop	ebx

; 599  : 				}
; 600  : 				return;
; 601  : 			}
; 602  : 		}
; 603  : 	}
; 604  : }

	add	esp, 36					; 00000024H
	ret	20					; 00000014H
?FillLineObstacle@KIpoTree@@AAEXHHHHH@Z ENDP		; KIpoTree::FillLineObstacle
_TEXT	ENDS
PUBLIC	__real@8@3fff8000000000000000
PUBLIC	__real@8@400f8000000000000000
PUBLIC	?CanLighting@KIpoTree@@AAE_NHHHH@Z		; KIpoTree::CanLighting
;	COMDAT __real@8@3fff8000000000000000
; File D:\VisualStudio6\VisualStudio6portable-langman.congdongcviet\Microsoft Visual Studio\VC98\INCLUDE\list
CONST	SEGMENT
__real@8@3fff8000000000000000 DQ 03ff0000000000000r ; 1
CONST	ENDS
;	COMDAT __real@8@400f8000000000000000
CONST	SEGMENT
__real@8@400f8000000000000000 DQ 040f0000000000000r ; 65536
CONST	ENDS
;	COMDAT ?RenderLightMap@KIpoTree@@QAEXXZ
_TEXT	SEGMENT
_this$ = -92
_i$ = -24
_nLightPosX$90413 = -32
_nLightPosY$90414 = -36
_ur$90421 = -52
_ug$90422 = -48
_ub$90423 = -44
_j$90424 = -96
_y$90426 = -20
_gx$90427 = -68
_gy$90428 = -68
_fLightRadiusDenom$90430 = -56
_pdwLight$ = -32
?RenderLightMap@KIpoTree@@QAEXXZ PROC NEAR		; KIpoTree::RenderLightMap, COMDAT

; 941  : {

	sub	esp, 96					; 00000060H
	push	ebx
	mov	ebx, ecx
	push	ebp
	push	esi

; 942  : 	int nn = m_LightList.size();
; 943  : 	int j, nLightID=1;
; 944  : 
; 945  : 	m_dwAmbient = 0xff101010;
; 946  : 
; 947  : 	// 按环境光清空光照图
; 948  : 	DWORD dwR, dwG, dwB;
; 949  : 	dwR = (m_dwAmbient & 0x00ff0000) >>16;
; 950  : 	dwG = (m_dwAmbient & 0x0000ff00) >>8;
; 951  : 	dwB = m_dwAmbient & 0x000000ff;
; 952  :     KLColor *pTempColor = pLColor;

	mov	eax, DWORD PTR [ebx+73824]
	push	edi
	mov	DWORD PTR _this$[esp+112], ebx
	mov	DWORD PTR [ebx+92], -15724528		; ff101010H
	mov	edx, 1152				; 00000480H
$L90402:

; 953  :     
; 954  :     // 如果每一个颜色分量是2个字节,可以考虑多一个项,然后用一个MMX的寄存器存放
; 955  :     // 正好8个字节
; 956  : 	for(j=0; j < LIGHTING_GRID_WIDTH * LIGHTING_GRID_HEIGHT / 4; j++)
; 957  : 	{
; 958  : 			pTempColor[0].r = dwR;

	mov	ecx, 16					; 00000010H
	mov	WORD PTR [eax], cx

; 959  : 			pTempColor[1].r = dwR;

	mov	WORD PTR [eax+8], cx

; 960  : 			pTempColor[2].r = dwR;

	mov	WORD PTR [eax+16], cx

; 961  : 			pTempColor[3].r = dwR;

	mov	WORD PTR [eax+24], cx

; 962  : 
; 963  : 			pTempColor[0].g = dwG;

	mov	WORD PTR [eax+2], cx

; 964  : 			pTempColor[1].g = dwG;

	mov	WORD PTR [eax+10], cx

; 965  : 			pTempColor[2].g = dwG;

	mov	WORD PTR [eax+18], cx

; 966  : 			pTempColor[3].g = dwG;

	mov	WORD PTR [eax+26], cx

; 967  : 
; 968  : 
; 969  : 			pTempColor[0].b = dwB;

	mov	WORD PTR [eax+4], cx

; 970  : 			pTempColor[1].b = dwB;

	mov	WORD PTR [eax+12], cx

; 971  : 			pTempColor[2].b = dwB;

	mov	WORD PTR [eax+20], cx

; 972  : 			pTempColor[3].b = dwB;

	mov	WORD PTR [eax+28], cx

; 973  :             
; 974  :             pTempColor += 4;

	add	eax, 32					; 00000020H
	dec	edx
	jne	SHORT $L90402

; 975  : 	}
; 976  : 
; 977  : 	list<KLightBase*>::iterator i;
; 978  : 	// 计算每一个光源的光照结果
; 979  : 	for (i = m_LightList.begin(); i != m_LightList.end(); ++i)

	mov	eax, DWORD PTR [ebx+92276]
	mov	esi, DWORD PTR [eax]
	cmp	esi, eax
	mov	DWORD PTR _i$[esp+112], esi
	je	$L90411
	jmp	SHORT $L92812
$L92885:
	mov	esi, DWORD PTR _i$[esp+112]
$L92812:

; 980  : 	{
; 981  : 		nLightID++;
; 982  : 		KLightBase *pLight = *i;

	mov	ebp, DWORD PTR [esi+8]

; 983  : 		// 光源相对于九区域左上角的坐标
; 984  : 		int nLightPosX = pLight->m_oPosition.nX - m_nLeftTopX;

	mov	edi, DWORD PTR [ebx+76]

; 985  : 		int nLightPosY = pLight->m_oPosition.nY - m_nLeftTopY;

	mov	edx, DWORD PTR [ebx+80]
	mov	eax, DWORD PTR [ebp+8]
	mov	ecx, DWORD PTR [ebp+12]
	sub	eax, edi
	sub	ecx, edx
	mov	DWORD PTR _nLightPosX$90413[esp+112], eax
	mov	DWORD PTR _nLightPosY$90414[esp+112], ecx

; 986  : 		// 光源的格子坐标
; 987  : 		int nLightGridX = nLightPosX / LIGHTING_GRID_SIZEX;

	cdq
	and	edx, 31					; 0000001fH
	add	eax, edx
	mov	edi, eax

; 988  : 		int nLightGridY = nLightPosY / LIGHTING_GRID_SIZEY;

	mov	eax, ecx
	cdq
	and	edx, 31					; 0000001fH
	add	eax, edx
	mov	ecx, eax
	sar	edi, 5
	sar	ecx, 5

; 989  : 		if(nLightGridX < 0 || nLightGridX >= LIGHTING_GRID_WIDTH || 
; 990  : 			nLightGridY < 0 || nLightGridY >= LIGHTING_GRID_HEIGHT)

	test	edi, edi
	jl	$L90410
	cmp	edi, 48					; 00000030H
	jge	$L90410
	test	ecx, ecx
	jl	$L90410
	cmp	ecx, 96					; 00000060H
	jge	$L90410

; 991  : 			continue;
; 992  : 
; 993  : 		// 光源所在格子中心的坐标
; 994  : 		int nLightGridCenterX = nLightGridX * LIGHTING_GRID_SIZEX + LIGHTING_GRID_SIZEX / 2;
; 995  : 		int nLightGridCenterY = nLightGridY * LIGHTING_GRID_SIZEY + LIGHTING_GRID_SIZEY / 2;
; 996  : 
; 997  : 		// 获取光源的r，g，b分量
; 998  : 		unsigned int ur, ug, ub;
; 999  : 
; 1000 : 		ur = (pLight->m_dwColor & 0x00ff0000) >> 18;

	mov	eax, DWORD PTR [ebp+20]

; 1001 : 		ug = (pLight->m_dwColor & 0x0000ff00) >> 10;
; 1002 : 		ub = (pLight->m_dwColor & 0x000000ff) >> 2;
; 1003 : 
; 1004 : 		//float fr = (float)pLight->m_nRadius * (float)pLight->m_nRadius;
; 1005 : 
; 1006 : 		int j, x, y, gx, gy;
; 1007 : 		int nGridRadius = pLight->m_nRadius / LIGHTING_GRID_SIZEX;

	mov	ebp, DWORD PTR [ebp+24]
	mov	DWORD PTR -16+[esp+112], ebp
	mov	edx, eax

; 1008 :         float fLightRadiusDenom =  1.0 / ((float)pLight->m_nRadius);

	fild	DWORD PTR -16+[esp+112]
	shr	edx, 18					; 00000012H
	and	edx, 63					; 0000003fH
	mov	esi, edi
	fdivr	QWORD PTR __real@8@3fff8000000000000000
	mov	DWORD PTR _ur$90421[esp+112], edx
	mov	edx, eax
	shr	eax, 2
	shr	edx, 10					; 0000000aH
	and	eax, 63					; 0000003fH
	and	edx, 63					; 0000003fH
	mov	DWORD PTR _ub$90423[esp+112], eax
	mov	eax, ebp
	mov	DWORD PTR _ug$90422[esp+112], edx
	mov	ebx, ecx
	cdq
	and	edx, 31					; 0000001fH
	add	eax, edx
	shl	esi, 5
	shl	ebx, 5
	sar	eax, 5
	add	esi, 16					; 00000010H
	add	ebx, 16					; 00000010H

; 1009 :         //fLightRadiusDenom *= fLightRadiusDenom;
; 1010 :         unsigned int uDistance65536 = 0;
; 1011 :         KLColor *pCurPos = NULL;
; 1012 : 
; 1013 : 		
; 1014 : 		gy = nLightGridY - (nGridRadius - 1);
; 1015 : 		// 从中心点向外扩展计算光照强度
; 1016 : 		for(int r = 0; r < nGridRadius; r++)

	test	eax, eax
	fstp	DWORD PTR _fLightRadiusDenom$90430[esp+112]
	jle	$L92891
	lea	ebp, DWORD PTR [ecx+ecx*2]
	or	edx, -1
	shl	ebp, 4
	mov	DWORD PTR -28+[esp+112], ebp
	lea	ebp, DWORD PTR [ecx+1]
	mov	DWORD PTR -80+[esp+112], ebp
	mov	DWORD PTR -40+[esp+112], edi
	lea	ebp, DWORD PTR [ebp+ebp*2]
	mov	DWORD PTR -88+[esp+112], edx
	shl	ebp, 4
	mov	DWORD PTR -64+[esp+112], ebp
	lea	ebp, DWORD PTR [ebx+32]
	sub	ebx, esi
	sub	ecx, edi
	mov	DWORD PTR -60+[esp+112], esi
	mov	DWORD PTR -84+[esp+112], edi
	mov	DWORD PTR -76+[esp+112], esi
	mov	DWORD PTR -72+[esp+112], ebp
	mov	DWORD PTR -8+[esp+112], ebx
	mov	DWORD PTR -12+[esp+112], ecx
	mov	DWORD PTR -16+[esp+112], eax
$L90435:

; 1017 : 		{
; 1018 : 			gx = nLightGridX - r;

	mov	eax, DWORD PTR -84+[esp+112]

; 1019 : 			gy = nLightGridY - r;
; 1020 : 			if (!
; 1021 : 				((gx < 0) || (gy < 0))
; 1022 : 			)

	test	eax, eax
	mov	DWORD PTR _gx$90427[esp+112], eax
	jl	$L92888
	mov	ecx, DWORD PTR -80+[esp+112]
	dec	ecx
	test	ecx, ecx
	jl	$L92888

; 1023 : 			{
; 1024 : 				x = nLightGridCenterX - r * LIGHTING_GRID_SIZEX;
; 1025 : 				y = nLightGridCenterY - r * LIGHTING_GRID_SIZEY;
; 1026 : 				pCurPos = &pLColor[gy * LIGHTING_GRID_WIDTH + gx];

	mov	esi, DWORD PTR _this$[esp+112]
	mov	ecx, DWORD PTR -64+[esp+112]
	mov	edi, DWORD PTR -76+[esp+112]
	add	ecx, eax
	mov	esi, DWORD PTR [esi+73824]

; 1027 : 				for(j=0; j<(r * 2 + 1); j++)

	mov	DWORD PTR _j$90424[esp+112], 0
	lea	esi, DWORD PTR [esi+ecx*8-384]
	lea	ecx, DWORD PTR [edx+2]
	test	ecx, ecx
	jle	$L92888
$L90439:

; 1028 : 				{
; 1029 : 					if(CanLighting(x, y, nLightPosX, nLightPosY))

	mov	edx, DWORD PTR -72+[esp+112]
	mov	ebp, DWORD PTR _nLightPosY$90414[esp+112]
	mov	ebx, DWORD PTR _nLightPosX$90413[esp+112]
	mov	ecx, DWORD PTR _this$[esp+112]
	push	ebp
	lea	eax, DWORD PTR [edx-32]
	push	ebx
	push	eax
	push	edi
	call	?CanLighting@KIpoTree@@AAE_NHHHH@Z	; KIpoTree::CanLighting
	test	al, al
	je	SHORT $L90447

; 1030 : 					{
; 1031 : 						//float f = 65536.0 - ((float)(
; 1032 : 						//    (
; 1033 : 						//        ((float)(x - nLightPosX)) * ((float)(x - nLightPosX)) + 
; 1034 : 						//        ((float)(y - nLightPosY)) * ((float)(y - nLightPosY))
; 1035 : 						//    ) * 
; 1036 : 						//    fLightRadiusDenom *
; 1037 : 						//    65536.0
; 1038 : 						//));
; 1039 : 						float f = 65536.0 - ((float)(
; 1040 : 							sqrt(
; 1041 : 								(x - nLightPosX) * (x - nLightPosX) + 
; 1042 : 								(y - nLightPosY) * (y - nLightPosY)
; 1043 : 							) * 
; 1044 : 							fLightRadiusDenom * 
; 1045 : 							65536.0
; 1046 : 						));

	mov	eax, DWORD PTR -72+[esp+112]
	mov	ecx, edi
	sub	ecx, ebx
	add	eax, -32				; ffffffe0H
	mov	edx, ecx
	sub	eax, ebp
	imul	edx, ecx
	mov	ecx, eax
	imul	ecx, eax
	add	edx, ecx

; 1047 : 
; 1048 : 						uDistance65536 = (int)(f);

	mov	DWORD PTR -20+[esp+112], edx
	fild	DWORD PTR -20+[esp+112]
	fsqrt
	fmul	DWORD PTR _fLightRadiusDenom$90430[esp+112]
	fmul	QWORD PTR __real@8@400f8000000000000000
	fsubr	QWORD PTR __real@8@400f8000000000000000
	call	__ftol

; 1049 : 
; 1050 : 						if (((int)uDistance65536) > 0)

	test	eax, eax
	jle	SHORT $L90447

; 1051 : 						{
; 1052 : 							pCurPos->r += (ur * uDistance65536 / 65536);

	mov	edx, eax

; 1053 : 							pCurPos->g += (ug * uDistance65536 / 65536);

	mov	ecx, eax
	imul	edx, DWORD PTR _ur$90421[esp+112]
	imul	ecx, DWORD PTR _ug$90422[esp+112]

; 1054 : 							pCurPos->b += (ub * uDistance65536 / 65536);

	imul	eax, DWORD PTR _ub$90423[esp+112]
	shr	edx, 16					; 00000010H
	add	WORD PTR [esi], dx
	shr	ecx, 16					; 00000010H
	add	WORD PTR [esi+2], cx
	shr	eax, 16					; 00000010H
	add	WORD PTR [esi+4], ax
$L90447:

; 1055 : 						}
; 1056 : 					}
; 1057 : 
; 1058 : 					gx++;

	mov	eax, DWORD PTR _gx$90427[esp+112]
	inc	eax

; 1059 :                     if (gx >= LIGHTING_GRID_WIDTH)

	cmp	eax, 48					; 00000030H
	mov	DWORD PTR _gx$90427[esp+112], eax
	jge	SHORT $L92880
	mov	edx, DWORD PTR -88+[esp+112]
	mov	eax, DWORD PTR _j$90424[esp+112]

; 1060 :                         break;
; 1061 : 
; 1062 : 					x += LIGHTING_GRID_SIZEX;

	add	edi, 32					; 00000020H

; 1063 : 					pCurPos++;

	add	esi, 8
	inc	eax
	lea	ecx, DWORD PTR [edx+2]
	cmp	eax, ecx
	mov	DWORD PTR _j$90424[esp+112], eax
	jl	$L90439
$L92880:

; 1027 : 				for(j=0; j<(r * 2 + 1); j++)

	mov	edx, DWORD PTR -88+[esp+112]
	mov	eax, DWORD PTR -84+[esp+112]
	jmp	SHORT $L92861
$L92888:
	mov	ebp, DWORD PTR _nLightPosY$90414[esp+112]
	mov	ebx, DWORD PTR _nLightPosX$90413[esp+112]
$L92861:

; 1064 : 				}
; 1065 : 			}
; 1066 : 
; 1067 : 			if(r == 0)

	cmp	edx, -1
	je	$L90436

; 1068 : 				continue;
; 1069 : 
; 1070 : 			gx = nLightGridX - r;
; 1071 : 			gy = nLightGridY + r;
; 1072 : 			if (!
; 1073 : 					((gx < 0) || (gy >= LIGHTING_GRID_HEIGHT))
; 1074 : 			)

	test	eax, eax
	mov	DWORD PTR _gx$90427[esp+112], eax
	jl	$L92862
	mov	ecx, DWORD PTR -12+[esp+112]
	mov	esi, DWORD PTR -40+[esp+112]
	add	ecx, esi
	cmp	ecx, 96					; 00000060H
	jge	$L92862

; 1075 : 			{
; 1076 : 				x = nLightGridCenterX - r * LIGHTING_GRID_SIZEX;
; 1077 : 				y = nLightGridCenterY + r * LIGHTING_GRID_SIZEY;

	mov	ecx, DWORD PTR -8+[esp+112]
	mov	esi, DWORD PTR -60+[esp+112]
	add	ecx, esi

; 1078 : 				pCurPos = &pLColor[gy * LIGHTING_GRID_WIDTH + gx];

	mov	esi, DWORD PTR _this$[esp+112]
	mov	DWORD PTR _y$90426[esp+112], ecx
	mov	ecx, DWORD PTR -28+[esp+112]
	mov	esi, DWORD PTR [esi+73824]
	mov	edi, DWORD PTR -76+[esp+112]
	add	ecx, eax

; 1079 : 				for(j=0; j<(r * 2 + 1); j++)

	mov	DWORD PTR _j$90424[esp+112], 0
	lea	esi, DWORD PTR [esi+ecx*8]
	lea	ecx, DWORD PTR [edx+2]
	test	ecx, ecx
	jle	$L92862
$L90451:

; 1080 : 				{
; 1081 : 					if(CanLighting(x, y, nLightPosX, nLightPosY))

	mov	edx, DWORD PTR _y$90426[esp+112]
	mov	ecx, DWORD PTR _this$[esp+112]
	push	ebp
	push	ebx
	push	edx
	push	edi
	call	?CanLighting@KIpoTree@@AAE_NHHHH@Z	; KIpoTree::CanLighting
	test	al, al
	je	SHORT $L90459

; 1082 : 					{
; 1083 : 						//float f = 65536.0 - ((float)(
; 1084 : 						//    (
; 1085 : 						//        ((float)(x - nLightPosX)) * ((float)(x - nLightPosX)) + 
; 1086 : 						//        ((float)(y - nLightPosY)) * ((float)(y - nLightPosY))
; 1087 : 						//    ) * 
; 1088 : 						//    fLightRadiusDenom *
; 1089 : 						//    65536.0
; 1090 : 						//));
; 1091 : 						float f = 65536.0 - ((float)(
; 1092 : 							sqrt(
; 1093 : 								(x - nLightPosX) * (x - nLightPosX) + 
; 1094 : 								(y - nLightPosY) * (y - nLightPosY)
; 1095 : 							) * 
; 1096 : 							fLightRadiusDenom * 
; 1097 : 							65536.0
; 1098 : 						));

	mov	eax, DWORD PTR _y$90426[esp+112]
	mov	ecx, edi
	sub	ecx, ebx
	sub	eax, ebp
	mov	edx, ecx
	imul	edx, ecx
	mov	ecx, eax
	imul	ecx, eax
	add	edx, ecx

; 1099 : 
; 1100 : 						uDistance65536 = (int)(f);

	mov	DWORD PTR -4+[esp+112], edx
	fild	DWORD PTR -4+[esp+112]
	fsqrt
	fmul	DWORD PTR _fLightRadiusDenom$90430[esp+112]
	fmul	QWORD PTR __real@8@400f8000000000000000
	fsubr	QWORD PTR __real@8@400f8000000000000000
	call	__ftol

; 1101 : 
; 1102 : 						if (((int)uDistance65536) > 0)

	test	eax, eax
	jle	SHORT $L90459

; 1103 : 						{
; 1104 : 							pCurPos->r += (ur * uDistance65536 / 65536);

	mov	edx, eax

; 1105 : 							pCurPos->g += (ug * uDistance65536 / 65536);

	mov	ecx, eax
	imul	edx, DWORD PTR _ur$90421[esp+112]
	imul	ecx, DWORD PTR _ug$90422[esp+112]

; 1106 : 							pCurPos->b += (ub * uDistance65536 / 65536);

	imul	eax, DWORD PTR _ub$90423[esp+112]
	shr	edx, 16					; 00000010H
	add	WORD PTR [esi], dx
	shr	ecx, 16					; 00000010H
	add	WORD PTR [esi+2], cx
	shr	eax, 16					; 00000010H
	add	WORD PTR [esi+4], ax
$L90459:

; 1107 : 						}
; 1108 : 					}
; 1109 : 
; 1110 : 					gx++;

	mov	eax, DWORD PTR _gx$90427[esp+112]
	inc	eax

; 1111 :                     if (gx >= LIGHTING_GRID_WIDTH)

	cmp	eax, 48					; 00000030H
	mov	DWORD PTR _gx$90427[esp+112], eax
	jge	SHORT $L92881
	mov	edx, DWORD PTR -88+[esp+112]
	mov	eax, DWORD PTR _j$90424[esp+112]

; 1112 :                         break;
; 1113 : 
; 1114 : 					x += LIGHTING_GRID_SIZEX;

	add	edi, 32					; 00000020H

; 1115 : 					pCurPos++;

	add	esi, 8
	inc	eax
	lea	ecx, DWORD PTR [edx+2]
	cmp	eax, ecx
	mov	DWORD PTR _j$90424[esp+112], eax
	jl	$L90451
$L92881:

; 1079 : 				for(j=0; j<(r * 2 + 1); j++)

	mov	edx, DWORD PTR -88+[esp+112]
	mov	eax, DWORD PTR -84+[esp+112]
$L92862:

; 1116 : 				}
; 1117 : 			}
; 1118 : 
; 1119 : 			gx = nLightGridX - r;
; 1120 : 			gy = nLightGridY - (r - 1);

	mov	ecx, DWORD PTR -80+[esp+112]

; 1121 : 			if (!
; 1122 : 				((gx < 0) || (gy < 0))
; 1123 : 			)

	test	eax, eax
	mov	DWORD PTR _gy$90428[esp+112], ecx
	jl	$L92863
	test	ecx, ecx
	jl	$L92863

; 1124 : 			{
; 1125 : 				x = nLightGridCenterX - r * LIGHTING_GRID_SIZEX;
; 1126 : 				y = nLightGridCenterY - (r - 1) * LIGHTING_GRID_SIZEY;
; 1127 : 				pCurPos = &pLColor[gy * LIGHTING_GRID_WIDTH + gx];

	mov	esi, DWORD PTR _this$[esp+112]
	mov	ecx, DWORD PTR -64+[esp+112]
	mov	edi, DWORD PTR -72+[esp+112]
	add	ecx, eax
	mov	esi, DWORD PTR [esi+73824]

; 1128 : 				for(j=0; j<(r * 2 - 1); j++)

	mov	DWORD PTR _j$90424[esp+112], 0
	test	edx, edx
	lea	esi, DWORD PTR [esi+ecx*8]
	jle	$L92863
$L90462:

; 1129 : 				{
; 1130 : 					if(CanLighting(x, y, nLightPosX, nLightPosY))

	mov	edx, DWORD PTR -76+[esp+112]
	mov	ecx, DWORD PTR _this$[esp+112]
	push	ebp
	push	ebx
	push	edi
	push	edx
	call	?CanLighting@KIpoTree@@AAE_NHHHH@Z	; KIpoTree::CanLighting
	test	al, al
	je	SHORT $L90470

; 1131 : 					{
; 1132 : 						//float f = 65536.0 - ((float)(
; 1133 : 						//    (
; 1134 : 						//        ((float)(x - nLightPosX)) * ((float)(x - nLightPosX)) + 
; 1135 : 						//        ((float)(y - nLightPosY)) * ((float)(y - nLightPosY))
; 1136 : 						//    ) * 
; 1137 : 						//    fLightRadiusDenom *
; 1138 : 						//    65536.0
; 1139 : 						//));
; 1140 : 						float f = 65536.0 - ((float)(
; 1141 : 							sqrt(
; 1142 : 								(x - nLightPosX) * (x - nLightPosX) + 
; 1143 : 								(y - nLightPosY) * (y - nLightPosY)
; 1144 : 							) * 
; 1145 : 							fLightRadiusDenom * 
; 1146 : 							65536.0
; 1147 : 						));

	mov	ecx, DWORD PTR -76+[esp+112]
	mov	eax, edi
	sub	ecx, ebx
	sub	eax, ebp
	mov	edx, ecx
	imul	edx, ecx
	mov	ecx, eax
	imul	ecx, eax
	add	edx, ecx

; 1148 : 
; 1149 : 						uDistance65536 = (int)(f);

	mov	DWORD PTR -4+[esp+112], edx
	fild	DWORD PTR -4+[esp+112]
	fsqrt
	fmul	DWORD PTR _fLightRadiusDenom$90430[esp+112]
	fmul	QWORD PTR __real@8@400f8000000000000000
	fsubr	QWORD PTR __real@8@400f8000000000000000
	call	__ftol

; 1150 : 
; 1151 : 						if (((int)uDistance65536) > 0)

	test	eax, eax
	jle	SHORT $L90470

; 1152 : 						{
; 1153 : 							pCurPos->r += (ur * uDistance65536 / 65536);

	mov	edx, eax

; 1154 : 							pCurPos->g += (ug * uDistance65536 / 65536);

	mov	ecx, eax
	imul	edx, DWORD PTR _ur$90421[esp+112]
	imul	ecx, DWORD PTR _ug$90422[esp+112]

; 1155 : 							pCurPos->b += (ub * uDistance65536 / 65536);

	imul	eax, DWORD PTR _ub$90423[esp+112]
	shr	edx, 16					; 00000010H
	add	WORD PTR [esi], dx
	shr	ecx, 16					; 00000010H
	add	WORD PTR [esi+2], cx
	shr	eax, 16					; 00000010H
	add	WORD PTR [esi+4], ax
$L90470:

; 1156 : 						}
; 1157 : 					}
; 1158 : 
; 1159 : 					gy++;

	mov	eax, DWORD PTR _gy$90428[esp+112]
	inc	eax

; 1160 :                     if (gy >= LIGHTING_GRID_HEIGHT)

	cmp	eax, 96					; 00000060H
	mov	DWORD PTR _gy$90428[esp+112], eax
	jge	SHORT $L92882
	mov	eax, DWORD PTR _j$90424[esp+112]
	mov	ecx, DWORD PTR -88+[esp+112]

; 1161 :                         break;
; 1162 : 
; 1163 : 					y += LIGHTING_GRID_SIZEX;

	add	edi, 32					; 00000020H

; 1164 : 					pCurPos += LIGHTING_GRID_WIDTH;

	add	esi, 384				; 00000180H
	inc	eax
	cmp	eax, ecx
	mov	DWORD PTR _j$90424[esp+112], eax
	jl	$L90462
$L92882:

; 1128 : 				for(j=0; j<(r * 2 - 1); j++)

	mov	edx, DWORD PTR -88+[esp+112]
	mov	eax, DWORD PTR -84+[esp+112]
$L92863:

; 1165 : 				}
; 1166 : 			}
; 1167 : 
; 1168 : 			
; 1169 : 			gx = nLightGridX + r;
; 1170 : 			gy = nLightGridY - (r - 1);
; 1171 : 			if (!
; 1172 : 				((gx >= LIGHTING_GRID_WIDTH ) || (gy < 0))
; 1173 : 			)

	mov	ecx, DWORD PTR -40+[esp+112]
	mov	esi, DWORD PTR -80+[esp+112]
	cmp	ecx, 48					; 00000030H
	mov	DWORD PTR _gy$90428[esp+112], esi
	jge	$L90436
	test	esi, esi
	jl	$L90436

; 1174 : 			{
; 1175 : 				x = nLightGridCenterX + r * LIGHTING_GRID_SIZEX;
; 1176 : 				y = nLightGridCenterY - (r - 1) * LIGHTING_GRID_SIZEY;
; 1177 : 				pCurPos = &pLColor[gy * LIGHTING_GRID_WIDTH + gx];

	mov	esi, DWORD PTR -64+[esp+112]
	mov	edi, DWORD PTR -72+[esp+112]
	add	esi, ecx
	mov	ecx, DWORD PTR _this$[esp+112]

; 1178 : 				for(j=0; j<(r * 2 - 1); j++)

	test	edx, edx
	mov	ecx, DWORD PTR [ecx+73824]
	mov	DWORD PTR _j$90424[esp+112], 0
	lea	esi, DWORD PTR [ecx+esi*8]
	jle	$L90436
$L90473:

; 1179 : 				{
; 1180 : 					if(CanLighting(x, y, nLightPosX, nLightPosY))

	mov	edx, DWORD PTR -60+[esp+112]
	mov	ecx, DWORD PTR _this$[esp+112]
	push	ebp
	push	ebx
	push	edi
	push	edx
	call	?CanLighting@KIpoTree@@AAE_NHHHH@Z	; KIpoTree::CanLighting
	test	al, al
	je	SHORT $L90481

; 1181 : 					{
; 1182 : 						//float f = 65536.0 - ((float)(
; 1183 : 						//    (
; 1184 : 						//        ((float)(x - nLightPosX)) * ((float)(x - nLightPosX)) + 
; 1185 : 						//        ((float)(y - nLightPosY)) * ((float)(y - nLightPosY))
; 1186 : 						//    ) * 
; 1187 : 						//    fLightRadiusDenom *
; 1188 : 						//    65536.0
; 1189 : 						//));
; 1190 : 						float f = 65536.0 - ((float)(
; 1191 : 							sqrt(
; 1192 : 								(x - nLightPosX) * (x - nLightPosX) + 
; 1193 : 								(y - nLightPosY) * (y - nLightPosY)
; 1194 : 							) * 
; 1195 : 							fLightRadiusDenom * 
; 1196 : 							65536.0
; 1197 : 						));

	mov	ecx, DWORD PTR -60+[esp+112]
	mov	eax, edi
	sub	ecx, ebx
	sub	eax, ebp
	mov	edx, ecx
	imul	edx, ecx
	mov	ecx, eax
	imul	ecx, eax
	add	edx, ecx

; 1198 : 
; 1199 : 						uDistance65536 = (int)(f);

	mov	DWORD PTR -4+[esp+112], edx
	fild	DWORD PTR -4+[esp+112]
	fsqrt
	fmul	DWORD PTR _fLightRadiusDenom$90430[esp+112]
	fmul	QWORD PTR __real@8@400f8000000000000000
	fsubr	QWORD PTR __real@8@400f8000000000000000
	call	__ftol

; 1200 : 
; 1201 : 						if (((int)uDistance65536) > 0)

	test	eax, eax
	jle	SHORT $L90481

; 1202 : 						{
; 1203 : 							pCurPos->r += (ur * uDistance65536 / 65536);

	mov	edx, eax

; 1204 : 							pCurPos->g += (ug * uDistance65536 / 65536);

	mov	ecx, eax
	imul	edx, DWORD PTR _ur$90421[esp+112]
	imul	ecx, DWORD PTR _ug$90422[esp+112]

; 1205 : 							pCurPos->b += (ub * uDistance65536 / 65536);

	imul	eax, DWORD PTR _ub$90423[esp+112]
	shr	edx, 16					; 00000010H
	add	WORD PTR [esi], dx
	shr	ecx, 16					; 00000010H
	add	WORD PTR [esi+2], cx
	shr	eax, 16					; 00000010H
	add	WORD PTR [esi+4], ax
$L90481:

; 1206 : 						}
; 1207 : 					}
; 1208 : 
; 1209 : 					gy++;

	mov	eax, DWORD PTR _gy$90428[esp+112]
	inc	eax

; 1210 :                     if (gy >= LIGHTING_GRID_HEIGHT)

	cmp	eax, 96					; 00000060H
	mov	DWORD PTR _gy$90428[esp+112], eax
	jge	SHORT $L92883
	mov	eax, DWORD PTR _j$90424[esp+112]
	mov	ecx, DWORD PTR -88+[esp+112]

; 1211 :                         break;
; 1212 : 
; 1213 : 					y += LIGHTING_GRID_SIZEX;

	add	edi, 32					; 00000020H

; 1214 : 					pCurPos += LIGHTING_GRID_WIDTH;

	add	esi, 384				; 00000180H
	inc	eax
	cmp	eax, ecx
	mov	DWORD PTR _j$90424[esp+112], eax
	jl	$L90473
$L92883:

; 1178 : 				for(j=0; j<(r * 2 - 1); j++)

	mov	edx, DWORD PTR -88+[esp+112]
	mov	eax, DWORD PTR -84+[esp+112]
$L90436:
	mov	ebx, DWORD PTR -28+[esp+112]
	mov	edi, DWORD PTR -40+[esp+112]
	mov	ecx, 48					; 00000030H
	mov	esi, DWORD PTR -72+[esp+112]
	add	ebx, ecx
	inc	edi
	dec	eax
	mov	ebp, DWORD PTR -64+[esp+112]
	mov	DWORD PTR -84+[esp+112], eax
	mov	eax, DWORD PTR -80+[esp+112]
	dec	eax
	mov	DWORD PTR -28+[esp+112], ebx
	mov	ebx, DWORD PTR -60+[esp+112]
	mov	DWORD PTR -40+[esp+112], edi
	mov	edi, DWORD PTR -76+[esp+112]
	mov	DWORD PTR -80+[esp+112], eax
	mov	eax, 32					; 00000020H
	sub	ebp, ecx
	add	ebx, eax
	sub	edi, eax
	sub	esi, eax
	mov	eax, DWORD PTR -16+[esp+112]
	add	edx, 2
	dec	eax
	mov	DWORD PTR -64+[esp+112], ebp
	mov	DWORD PTR -60+[esp+112], ebx
	mov	DWORD PTR -76+[esp+112], edi
	mov	DWORD PTR -72+[esp+112], esi
	mov	DWORD PTR -88+[esp+112], edx
	mov	DWORD PTR -16+[esp+112], eax
	jne	$L90435
$L92891:

; 1009 :         //fLightRadiusDenom *= fLightRadiusDenom;
; 1010 :         unsigned int uDistance65536 = 0;
; 1011 :         KLColor *pCurPos = NULL;
; 1012 : 
; 1013 : 		
; 1014 : 		gy = nLightGridY - (nGridRadius - 1);
; 1015 : 		// 从中心点向外扩展计算光照强度
; 1016 : 		for(int r = 0; r < nGridRadius; r++)

	mov	esi, DWORD PTR _i$[esp+112]
	mov	ebx, DWORD PTR _this$[esp+112]
$L90410:
	mov	esi, DWORD PTR [esi]
	mov	eax, DWORD PTR [ebx+92276]
	cmp	esi, eax
	mov	DWORD PTR _i$[esp+112], esi
	jne	$L92885
$L90411:

; 1215 : 				}
; 1216 : 			}
; 1217 : 		}
; 1218 : 	}
; 1219 : 
; 1220 :     //memcpy(ptp, pLColor, sizeof(ptp));
; 1221 : 
; 1222 :     
; 1223 : 	// 对光照图进行过滤，使阴影边沿平滑
; 1224 :     
; 1225 : 
; 1226 : 	int m;
; 1227 :     int n;
; 1228 :     DWORD   *pdwLight;
; 1229 :     KLColor *pO, *pL, *pR, *pU, *pD, *pDest;
; 1230 :     int nIdx = 1 * LIGHTING_GRID_WIDTH + 1;

	mov	esi, 392				; 00000188H
	lea	edx, DWORD PTR [ebx+74036]
	mov	DWORD PTR -28+[esp+112], esi
	mov	DWORD PTR -24+[esp+112], edx
	mov	DWORD PTR -40+[esp+112], 94		; 0000005eH
	jmp	SHORT $L90493
$L92884:
	mov	esi, DWORD PTR -28+[esp+112]
	mov	ebx, DWORD PTR _this$[esp+112]
$L90493:

; 1231 : 	for(m=1; m<LIGHTING_GRID_HEIGHT-1;m++)
; 1232 : 	{
; 1233 : 		pDest = ptp + nIdx;
; 1234 :         pdwLight = pLightingArray + nIdx;

	mov	eax, DWORD PTR -24+[esp+112]
	mov	edx, DWORD PTR [ebx+73832]
	mov	ecx, esi
	mov	DWORD PTR _pdwLight$[esp+112], eax

; 1235 : 		pO = pLColor + nIdx;

	mov	eax, DWORD PTR [ebx+73824]
	add	ecx, edx
	add	esi, eax
	mov	DWORD PTR -36+[esp+112], 46		; 0000002eH

; 1236 : 		pL = pO - 1;

	lea	edi, DWORD PTR [esi-8]

; 1237 : 		pR = pO + 1;
; 1238 : 		pU = pO - LIGHTING_GRID_WIDTH;

	lea	ebx, DWORD PTR [esi-384]

; 1239 : 		pD = pO + LIGHTING_GRID_WIDTH;

	lea	ebp, DWORD PTR [esi+384]
$L90496:

; 1240 : 		for(n=1; n<LIGHTING_GRID_WIDTH-1;n++)
; 1241 : 		{
; 1242 : 			//pDest->r = (pO->r + pR->r + pL->r + pU->r + pD->r) / 5;
; 1243 : 			//pDest->g = (pO->g + pR->g + pL->g + pU->g + pD->g) / 5;
; 1244 : 			//pDest->b = (pO->b + pR->b + pL->b + pU->b + pD->b) / 5;
; 1245 : 			//pDest->r = (pO->r + pR->r + pL->r + (pU->r + pD->r) / 2) / 4;
; 1246 : 			//pDest->g = (pO->g + pR->g + pL->g + (pU->g + pD->g) / 2) / 4;
; 1247 : 			//pDest->b = (pO->b + pR->b + pL->b + (pU->b + pD->b) / 2) / 4;
; 1248 : 			//pDest->r = (pO->r + (pR->r + pL->r) / 2 + pU->r + pD->r) / 4;
; 1249 : 			//pDest->g = (pO->g + (pR->g + pL->g) / 2 + pU->g + pD->g) / 4;
; 1250 : 			//pDest->b = (pO->b + (pR->b + pL->b) / 2 + pU->b + pD->b) / 4;
; 1251 : 			
; 1252 :             pDest->r = (pO->r + pL->r + pU->r + pD->r) / 4;

	xor	eax, eax
	xor	edx, edx
	mov	ax, WORD PTR [ebp]
	mov	dx, WORD PTR [ebx]
	add	eax, edx
	xor	edx, edx
	mov	dx, WORD PTR [edi]
	add	eax, edx
	xor	edx, edx
	mov	dx, WORD PTR [esi]
	add	eax, edx
	cdq
	and	edx, 3
	add	eax, edx

; 1253 : 		    pDest->g = (pO->g + pL->g + pU->g + pD->g) / 4;

	xor	edx, edx
	sar	eax, 2
	mov	WORD PTR [ecx], ax
	mov	dx, WORD PTR [ebx+2]
	xor	eax, eax
	mov	ax, WORD PTR [ebp+2]
	add	eax, edx
	xor	edx, edx
	mov	dx, WORD PTR [edi+2]
	add	eax, edx
	xor	edx, edx
	mov	dx, WORD PTR [esi+2]
	add	eax, edx
	cdq
	and	edx, 3
	add	eax, edx

; 1254 : 			pDest->b = (pO->b + pL->b + pU->b + pD->b) / 4;

	xor	edx, edx
	sar	eax, 2
	mov	WORD PTR [ecx+2], ax
	mov	dx, WORD PTR [ebx+4]
	xor	eax, eax
	mov	ax, WORD PTR [ebp+4]
	add	eax, edx
	xor	edx, edx
	mov	dx, WORD PTR [edi+4]
	add	eax, edx
	xor	edx, edx
	mov	dx, WORD PTR [esi+4]
	add	eax, edx
	cdq
	and	edx, 3
	add	eax, edx
	sar	eax, 2

; 1255 : 
; 1256 :             *pdwLight = 0xff000000 |
; 1257 :                 (((pDest->r > 0xff) ? 0xff : pDest->r) << 16) |
; 1258 :                 (((pDest->g > 0xff) ? 0xff : pDest->g) << 8) |
; 1259 :                 (((pDest->b > 0xff) ? 0xff : pDest->b));

	cmp	WORD PTR [ecx], 255			; 000000ffH
	mov	WORD PTR [ecx+4], ax
	jbe	SHORT $L92766
	mov	eax, 255				; 000000ffH
	jmp	SHORT $L92767
$L92766:
	xor	eax, eax
	mov	ax, WORD PTR [ecx]
$L92767:
	mov	dx, WORD PTR [ecx+2]
	cmp	dx, 255					; 000000ffH
	jbe	SHORT $L92768
	mov	DWORD PTR -16+[esp+112], 255		; 000000ffH
	jmp	SHORT $L92769
$L92768:
	and	edx, 65535				; 0000ffffH
	mov	DWORD PTR -16+[esp+112], edx
$L92769:
	mov	dx, WORD PTR [ecx+4]
	cmp	dx, 255					; 000000ffH
	jbe	SHORT $L92770
	mov	DWORD PTR -20+[esp+112], 255		; 000000ffH
	jmp	SHORT $L92771
$L92770:
	and	edx, 65535				; 0000ffffH
	mov	DWORD PTR -20+[esp+112], edx
$L92771:
	mov	edx, DWORD PTR -16+[esp+112]
	or	eax, -256				; ffffff00H
	shl	eax, 8
	or	eax, edx
	mov	edx, DWORD PTR -20+[esp+112]
	shl	eax, 8
	or	eax, edx
	mov	edx, DWORD PTR _pdwLight$[esp+112]

; 1260 : 
; 1261 : 
; 1262 :             //pDest->r = pO->r;
; 1263 : 		    //pDest->g = pO->g;
; 1264 : 			//pDest->b = pO->b;
; 1265 : 
; 1266 : 			pDest++, pO++, pL++, pR++, pU++, pD++, pdwLight++;

	add	ecx, 8
	add	esi, 8
	mov	DWORD PTR [edx], eax
	mov	eax, DWORD PTR -36+[esp+112]
	add	edi, 8
	add	ebx, 8
	add	ebp, 8
	add	edx, 4
	dec	eax
	mov	DWORD PTR _pdwLight$[esp+112], edx
	mov	DWORD PTR -36+[esp+112], eax
	jne	$L90496

; 1267 : 		}
; 1268 : 		nIdx += LIGHTING_GRID_WIDTH;

	mov	edx, DWORD PTR -24+[esp+112]
	mov	ecx, DWORD PTR -28+[esp+112]
	mov	eax, DWORD PTR -40+[esp+112]
	add	edx, 192				; 000000c0H
	add	ecx, 384				; 00000180H
	dec	eax
	mov	DWORD PTR -24+[esp+112], edx
	mov	DWORD PTR -28+[esp+112], ecx
	mov	DWORD PTR -40+[esp+112], eax
	jne	$L92884

; 1269 : 	}
; 1270 :     
; 1271 : 
; 1272 : 	// 将r，g，b的值限制在0xff之内，防止色彩错误
; 1273 : //	for(j = 0; j < LIGHTING_GRID_WIDTH * LIGHTING_GRID_HEIGHT; j++)
; 1274 : //	{
; 1275 : //        //pLightingArray[j] = 0xff000000 |
; 1276 : //        //    ((((-(ptp[j].r > 0xff)) | ptp[j].r) & 0xff) << 16) |
; 1277 : //        //    ((((-(ptp[j].g > 0xff)) | ptp[j].g) & 0xff) << 8) |
; 1278 : //        //    ((((-(ptp[j].b > 0xff)) | ptp[j].b) & 0xff));
; 1279 : //
; 1280 : //		//if(ptp[j].r > 0xff)
; 1281 : //		//	ptp[j].r = 0xff;
; 1282 : //        
; 1283 : //		//if(ptp[j].g > 0xff)
; 1284 : //		//	ptp[j].g = 0xff;
; 1285 : //		//if(ptp[j].b > 0xff)
; 1286 : //		//	ptp[j].b = 0xff;
; 1287 : //		//pLightingArray[j] = 0xff000000 | (ptp[j].r<<16) | (ptp[j].g<<8) | ptp[j].b;
; 1288 : //
; 1289 : //        pLightingArray[j] = 0xff000000 |
; 1290 : //            (((ptp[j].r > 0xff) ? 0xff : ptp[j].r) << 16) |
; 1291 : //            (((ptp[j].g > 0xff) ? 0xff : ptp[j].g) << 8) |
; 1292 : //            (((ptp[j].b > 0xff) ? 0xff : ptp[j].b));
; 1293 : //
; 1294 : //	}
; 1295 :     for (m = 0; m < LIGHTING_GRID_HEIGHT; m++)

	mov	eax, DWORD PTR _this$[esp+112]
	mov	edx, 96					; 00000060H
	lea	ecx, DWORD PTR [eax+74028]
$L90499:

; 1296 :     {
; 1297 :         pLightingArray[m * LIGHTING_GRID_WIDTH + 0] = m_dwAmbient | 0xff000000;

	mov	esi, DWORD PTR [eax+92]
	add	ecx, 192				; 000000c0H
	or	esi, -16777216				; ff000000H
	mov	DWORD PTR [ecx-380], esi

; 1298 :         pLightingArray[m * LIGHTING_GRID_WIDTH + LIGHTING_GRID_WIDTH - 1] = m_dwAmbient | 0xff000000;

	mov	esi, DWORD PTR [eax+92]
	or	esi, -16777216				; ff000000H
	dec	edx
	mov	DWORD PTR [ecx-192], esi
	jne	SHORT $L90499

; 1299 :     }
; 1300 : 
; 1301 :     for (n = 0; n < LIGHTING_GRID_WIDTH; n++)

	lea	ecx, DWORD PTR [eax+92080]
	mov	edx, 48					; 00000030H
$L90502:

; 1302 :     {
; 1303 :         pLightingArray[n] = m_dwAmbient | 0xff000000;

	mov	esi, DWORD PTR [eax+92]
	add	ecx, 4
	or	esi, -16777216				; ff000000H
	mov	DWORD PTR [ecx-18244], esi

; 1304 :         pLightingArray[(LIGHTING_GRID_HEIGHT - 1) * LIGHTING_GRID_WIDTH + n] = m_dwAmbient | 0xff000000;

	mov	esi, DWORD PTR [eax+92]
	or	esi, -16777216				; ff000000H
	dec	edx
	mov	DWORD PTR [ecx-4], esi
	jne	SHORT $L90502
	pop	edi
	pop	esi
	pop	ebp
	pop	ebx

; 1305 :     }
; 1306 :     //pLightingArray[0] = m_dwAmbient;    // 设置环境光
; 1307 : }

	add	esp, 96					; 00000060H
	ret	0
?RenderLightMap@KIpoTree@@QAEXXZ ENDP			; KIpoTree::RenderLightMap
_TEXT	ENDS
PUBLIC	__real@4@00000000000000000000
;	COMDAT __real@4@00000000000000000000
; File D:\Lam game phong than\PhongThanSource\Sources\Core\Src\Scene\KIpoTree.cpp
CONST	SEGMENT
__real@4@00000000000000000000 DD 000000000r	; 0
CONST	ENDS
;	COMDAT ?CanLighting@KIpoTree@@AAE_NHHHH@Z
_TEXT	SEGMENT
_x$ = 8
_y$ = 12
_nLightPosX$ = 16
_nLightPosY$ = 20
_nGridLightPosX$ = -24
_nGridLightPosY$ = -20
_nObstacle$ = -28
_vDir$ = -16
_vLight$ = -8
_fdx$ = -32
_fdy$ = 20
?CanLighting@KIpoTree@@AAE_NHHHH@Z PROC NEAR		; KIpoTree::CanLighting, COMDAT

; 1311 : {

	sub	esp, 32					; 00000020H

; 1312 : 	int nGridX, nGridY, nGridLightPosX, nGridLightPosY, nGridStep, nCurrentGridX, nCurrentGridY, nIdx;
; 1313 : 	nGridX = x / LIGHTING_GRID_SIZEX;

	mov	eax, DWORD PTR _x$[esp+28]
	push	ebx
	cdq
	and	edx, 31					; 0000001fH
	push	ebp
	add	eax, edx
	push	esi
	mov	ebx, eax

; 1314 : 	nGridY = y / LIGHTING_GRID_SIZEX;

	mov	eax, DWORD PTR _y$[esp+40]
	cdq
	and	edx, 31					; 0000001fH
	push	edi
	add	eax, edx
	mov	ebp, ecx
	mov	edi, eax

; 1315 : 	nGridLightPosX = nLightPosX / LIGHTING_GRID_SIZEX;

	mov	eax, DWORD PTR _nLightPosX$[esp+44]
	cdq
	and	edx, 31					; 0000001fH
	add	eax, edx
	mov	ecx, eax

; 1316 : 	nGridLightPosY = nLightPosY / LIGHTING_GRID_SIZEX;

	mov	eax, DWORD PTR _nLightPosY$[esp+44]
	cdq
	and	edx, 31					; 0000001fH
	add	edx, eax
	sar	ebx, 5
	sar	ecx, 5
	sar	edi, 5
	sar	edx, 5

; 1317 : 	if(nGridX == nGridLightPosX && nGridY == nGridLightPosY)

	cmp	ebx, ecx
	mov	DWORD PTR _nGridLightPosX$[esp+48], ecx
	mov	DWORD PTR _nGridLightPosY$[esp+48], edx
	jne	SHORT $L90520
	cmp	edi, edx
	jne	SHORT $L90520
	pop	edi
	pop	esi
	pop	ebp

; 1318 : 		return true;

	mov	al, 1
	pop	ebx

; 1419 : 		}
; 1420 : 	}
; 1421 : }

	add	esp, 32					; 00000020H
	ret	16					; 00000010H
$L90520:

; 1319 : 
; 1320 : 	int nObstacle = pObstacle[nGridY * LIGHTING_GRID_WIDTH + nGridX].nObstacle;

	lea	eax, DWORD PTR [edi+edi*2]
	shl	eax, 4
	add	eax, ebx
	lea	esi, DWORD PTR [eax+6]
	shl	esi, 4

; 1321 : 	KVector2 vDir = pObstacle[nGridY * LIGHTING_GRID_WIDTH + nGridX].vDir;

	shl	eax, 4
	mov	esi, DWORD PTR [esi+ebp]
	mov	DWORD PTR _nObstacle$[esp+48], esi
	mov	esi, DWORD PTR [eax+ebp+100]
	mov	eax, DWORD PTR [eax+ebp+104]
	mov	DWORD PTR _vDir$[esp+48], esi

; 1322 : 	KVector2 vLight;
; 1323 : 	vLight.fX = (float)(x - nLightPosX);

	mov	esi, DWORD PTR _nLightPosX$[esp+44]
	mov	DWORD PTR _vDir$[esp+52], eax
	mov	eax, DWORD PTR _x$[esp+44]
	sub	eax, esi

; 1324 : 	vLight.fY = (float)(y - nLightPosY);

	mov	esi, DWORD PTR _nLightPosY$[esp+44]
	mov	DWORD PTR -32+[esp+48], eax
	mov	eax, DWORD PTR _y$[esp+44]
	fild	DWORD PTR -32+[esp+48]
	sub	eax, esi
	mov	DWORD PTR -32+[esp+48], eax
	fstp	DWORD PTR _vLight$[esp+48]
	fild	DWORD PTR -32+[esp+48]
	fstp	DWORD PTR _vLight$[esp+52]

; 1325 : 
; 1326 : 	float fx, fy, fLightPosX, fLightPosY, fdx, fdy, fStepX, fStepY;
; 1327 : 	fx = (float)x, fy =(float) y, fLightPosX = (float)nLightPosX, fLightPosY = (float)nLightPosY;

	fild	DWORD PTR _x$[esp+44]
	fild	DWORD PTR _y$[esp+44]

; 1328 : 	fdx = (float)fabs(fLightPosX - fx);

	fild	DWORD PTR _nLightPosX$[esp+44]
	fsub	ST(0), ST(2)
	fabs
	fst	DWORD PTR _fdx$[esp+48]

; 1329 : 	fdy = (float)fabs(fLightPosY - fy);

	fild	DWORD PTR _nLightPosY$[esp+44]
	fsub	ST(0), ST(2)
	fabs
	fstp	DWORD PTR _fdy$[esp+44]

; 1330 : 
; 1331 : 	// 斜率小于45度的情况
; 1332 : 	if(fdx >= fdy)

	fcomp	DWORD PTR _fdy$[esp+44]
	fnstsw	ax
	test	ah, 1
	jne	$L90540

; 1333 : 	{
; 1334 : 		// 计算线段前进累加值
; 1335 : 		if(nLightPosX > x)

	mov	edx, DWORD PTR _x$[esp+44]
	mov	eax, DWORD PTR _nLightPosX$[esp+44]
	cmp	eax, edx
	jle	SHORT $L90541

; 1336 : 		{
; 1337 : 			nGridStep = 1;
; 1338 : 			fStepX = LIGHTING_GRID_SIZEX;

	fld	DWORD PTR __real@4@40048000000000000000
	mov	edi, 1

; 1339 : 		}
; 1340 : 		else

	jmp	SHORT $L90542
$L90541:

; 1341 : 		{
; 1342 : 			nGridStep = -1;
; 1343 : 			fStepX = -LIGHTING_GRID_SIZEX;

	fld	DWORD PTR __real@4@c0048000000000000000
	or	edi, -1
$L90542:

; 1344 : 		}
; 1345 : 		if(nLightPosY > y)

	mov	eax, DWORD PTR _y$[esp+44]

; 1346 : 			fStepY = fdy / fdx * LIGHTING_GRID_SIZEX;

	fld	DWORD PTR _fdy$[esp+44]
	fdiv	DWORD PTR _fdx$[esp+48]
	cmp	esi, eax
	jle	SHORT $L90543
	fmul	DWORD PTR __real@4@40048000000000000000

; 1347 : 		else

	jmp	SHORT $L90546
$L90543:

; 1348 : 			fStepY = -fdy / fdx * LIGHTING_GRID_SIZEX;

	fmul	DWORD PTR __real@4@c0048000000000000000

; 1349 : 
; 1350 : 		while(1)

	jmp	SHORT $L90546
$L92919:
	mov	ecx, DWORD PTR _nGridLightPosX$[esp+48]
$L90546:

; 1351 : 		{
; 1352 : 			fx += fStepX;

	fld	ST(1)
	faddp	ST(4), ST(0)

; 1353 : 			fy += fStepY;
; 1354 : 			nGridX += nGridStep;

	add	ebx, edi

; 1355 : 			if(nGridX == nGridLightPosX)

	cmp	ebx, ecx
	fld	ST(0)
	faddp	ST(3), ST(0)
	je	SHORT $L92911

; 1362 : 					else
; 1363 : 						return false;
; 1364 : 				}
; 1365 : 				else
; 1366 : 					return true;
; 1367 : 			}
; 1368 : 
; 1369 : 			nCurrentGridX = ((int)fx) / LIGHTING_GRID_SIZEX;
; 1370 : 			nCurrentGridY = ((int)fy) / LIGHTING_GRID_SIZEX;
; 1371 : 			nIdx = nCurrentGridY * LIGHTING_GRID_WIDTH + nCurrentGridX;

	fld	ST(2)
	call	__ftol
	cdq
	fld	ST(3)
	and	edx, 31					; 0000001fH
	add	eax, edx
	sar	eax, 5
	lea	esi, DWORD PTR [eax+eax*2]
	shl	esi, 4
	call	__ftol
	cdq
	and	edx, 31					; 0000001fH
	add	eax, edx
	sar	eax, 5
	add	esi, eax

; 1372 : 			// 检查是否碰到挡光障碍
; 1373 : 			if(pObstacle[nIdx].nObstacle != 0 && pObstacle[nIdx].nObstacle != nObstacle)

	add	esi, 6
	shl	esi, 4
	mov	eax, DWORD PTR [esi+ebp]
	test	eax, eax
	je	SHORT $L92919
	cmp	eax, DWORD PTR _nObstacle$[esp+48]
	jne	$L92910

; 1349 : 
; 1350 : 		while(1)

	jmp	SHORT $L92919
$L92911:

; 1356 : 			{
; 1357 : 				// 没有碰到障碍，根据这点本身是否障碍和障碍方向判断是否受光
; 1358 : 				if(nObstacle && vDir.fX != 0.0f)

	mov	eax, DWORD PTR _nObstacle$[esp+48]
	fstp	ST(0)
	fstp	ST(0)
	fstp	ST(0)
	test	eax, eax
	fstp	ST(0)
	je	SHORT $L90549
	fld	DWORD PTR _vDir$[esp+48]
	fcomp	DWORD PTR __real@4@00000000000000000000
	fnstsw	ax
	test	ah, 64					; 00000040H
	jne	SHORT $L90549

; 1359 : 				{
; 1360 : 					if(vDir.fX * vLight.fY - vDir.fY * vLight.fX < 0.0f)

	fld	DWORD PTR _vDir$[esp+48]
	fmul	DWORD PTR _vLight$[esp+52]
	fld	DWORD PTR _vDir$[esp+52]
	fmul	DWORD PTR _vLight$[esp+48]
	fsubp	ST(1), ST(0)
	fcomp	DWORD PTR __real@4@00000000000000000000
	fnstsw	ax
	test	ah, 1
	je	$L90566
$L90549:
	pop	edi
	pop	esi
	pop	ebp

; 1361 : 						return true;

	mov	al, 1
	pop	ebx

; 1419 : 		}
; 1420 : 	}
; 1421 : }

	add	esp, 32					; 00000020H
	ret	16					; 00000010H
$L90540:

; 1374 : 				return false;
; 1375 : 		}
; 1376 : 	}
; 1377 : 	// 斜率大于45度的情况
; 1378 : 	else
; 1379 : 	{
; 1380 : 		if(nLightPosY > y)

	cmp	esi, DWORD PTR _y$[esp+44]
	jle	SHORT $L90557

; 1381 : 		{
; 1382 : 			nGridStep = 1;
; 1383 : 			fStepY = LIGHTING_GRID_SIZEX;

	fld	DWORD PTR __real@4@40048000000000000000
	mov	ebx, 1

; 1384 : 		}
; 1385 : 		else

	jmp	SHORT $L90558
$L90557:

; 1386 : 		{
; 1387 : 			nGridStep = -1;
; 1388 : 			fStepY = -LIGHTING_GRID_SIZEX;

	fld	DWORD PTR __real@4@c0048000000000000000
	or	ebx, -1
$L90558:

; 1389 : 		}
; 1390 : 		if(nLightPosX > x)

	mov	eax, DWORD PTR _x$[esp+44]
	mov	ecx, DWORD PTR _nLightPosX$[esp+44]

; 1391 : 			fStepX = fdx / fdy * LIGHTING_GRID_SIZEX;

	fld	DWORD PTR _fdx$[esp+48]
	fdiv	DWORD PTR _fdy$[esp+44]
	cmp	ecx, eax
	jle	SHORT $L90559
	fmul	DWORD PTR __real@4@40048000000000000000

; 1392 : 		else

	jmp	SHORT $L90562
$L90559:

; 1393 : 			fStepX = -fdx / fdy * LIGHTING_GRID_SIZEX;

	fmul	DWORD PTR __real@4@c0048000000000000000

; 1394 : 		while(1)

	jmp	SHORT $L90562
$L92920:
	mov	edx, DWORD PTR _nGridLightPosY$[esp+48]
$L90562:

; 1395 : 		{
; 1396 : 			fx += fStepX;

	fld	ST(0)
	faddp	ST(4), ST(0)

; 1397 : 			fy += fStepY;
; 1398 : 			nGridY += nGridStep;

	add	edi, ebx
	fld	ST(1)

; 1399 : 			if(nGridY == nGridLightPosY)

	cmp	edi, edx
	faddp	ST(3), ST(0)
	je	$L92911

; 1400 : 			{
; 1401 : 				// 没有碰到障碍，根据这点本身是否障碍和障碍方向判断是否受光
; 1402 : 				if(nObstacle && vDir.fX != 0.0f)
; 1403 : 				{
; 1404 : 					if(vDir.fX * vLight.fY - vDir.fY * vLight.fX < 0.0f)
; 1405 : 						return true;
; 1406 : 					else
; 1407 : 						return false;
; 1408 : 				}
; 1409 : 				else
; 1410 : 					return true;
; 1411 : 			}
; 1412 : 
; 1413 : 			nCurrentGridX = ((int)fx) / LIGHTING_GRID_SIZEX;
; 1414 : 			nCurrentGridY = ((int)fy) / LIGHTING_GRID_SIZEX;
; 1415 : 			nIdx = nCurrentGridY * LIGHTING_GRID_WIDTH + nCurrentGridX;

	fld	ST(2)
	call	__ftol
	cdq
	fld	ST(3)
	and	edx, 31					; 0000001fH
	add	eax, edx
	sar	eax, 5
	lea	esi, DWORD PTR [eax+eax*2]
	shl	esi, 4
	call	__ftol
	cdq
	and	edx, 31					; 0000001fH
	add	eax, edx
	sar	eax, 5
	add	esi, eax

; 1416 : 			// 检查是否碰到挡光障碍
; 1417 : 			if(pObstacle[nIdx].nObstacle != 0 && pObstacle[nIdx].nObstacle != nObstacle)

	add	esi, 6
	shl	esi, 4
	mov	eax, DWORD PTR [esi+ebp]
	test	eax, eax
	je	SHORT $L92920
	cmp	eax, DWORD PTR _nObstacle$[esp+48]
	je	SHORT $L92920
$L92910:

; 1400 : 			{
; 1401 : 				// 没有碰到障碍，根据这点本身是否障碍和障碍方向判断是否受光
; 1402 : 				if(nObstacle && vDir.fX != 0.0f)
; 1403 : 				{
; 1404 : 					if(vDir.fX * vLight.fY - vDir.fY * vLight.fX < 0.0f)
; 1405 : 						return true;
; 1406 : 					else
; 1407 : 						return false;
; 1408 : 				}
; 1409 : 				else
; 1410 : 					return true;
; 1411 : 			}
; 1412 : 
; 1413 : 			nCurrentGridX = ((int)fx) / LIGHTING_GRID_SIZEX;
; 1414 : 			nCurrentGridY = ((int)fy) / LIGHTING_GRID_SIZEX;
; 1415 : 			nIdx = nCurrentGridY * LIGHTING_GRID_WIDTH + nCurrentGridX;

	fstp	ST(0)
	fstp	ST(0)
	fstp	ST(0)
	fstp	ST(0)
$L90566:
	pop	edi
	pop	esi
	pop	ebp

; 1418 : 				return false;

	xor	al, al
	pop	ebx

; 1419 : 		}
; 1420 : 	}
; 1421 : }

	add	esp, 32					; 00000020H
	ret	16					; 00000010H
?CanLighting@KIpoTree@@AAE_NHHHH@Z ENDP			; KIpoTree::CanLighting
_TEXT	ENDS
PUBLIC	?AddBuildinLight@KIpoTree@@QAEXPAUKBuildInLightInfo@@H@Z ; KIpoTree::AddBuildinLight
PUBLIC	__real@4@4005af00000000000000
EXTRN	__imp_?g_Random@@YAII@Z:NEAR
;	COMDAT __real@4@4005af00000000000000
; File D:\VisualStudio6\VisualStudio6portable-langman.congdongcviet\Microsoft Visual Studio\VC98\INCLUDE\list
CONST	SEGMENT
__real@4@4005af00000000000000 DD 042af0000r	; 87.5
CONST	ENDS
;	COMDAT ?AddBuildinLight@KIpoTree@@QAEXPAUKBuildInLightInfo@@H@Z
_TEXT	SEGMENT
_pLights$ = 8
_nCount$ = 12
_this$ = -20
_nMinRange$ = -12
_nMaxRange$ = 12
?AddBuildinLight@KIpoTree@@QAEXPAUKBuildInLightInfo@@H@Z PROC NEAR ; KIpoTree::AddBuildinLight, COMDAT

; 1538 : {

	sub	esp, 20					; 00000014H

; 1539 : 	if(!m_bProcessBioLights)

	mov	al, BYTE PTR [ecx+89]
	mov	DWORD PTR _this$[esp+20], ecx
	test	al, al
	je	$L90583

; 1540 : 		return;
; 1541 : 
; 1542 : 	int nMinRange, nMaxRange;
; 1543 : 
; 1544 : 	for(int i=0; i<nCount; i++)

	mov	eax, DWORD PTR _nCount$[esp+16]
	test	eax, eax
	jle	$L90583
	mov	ecx, DWORD PTR _pLights$[esp+16]
	push	ebx
	push	ebp
	push	esi
	push	edi
	lea	edi, DWORD PTR [ecx+20]
	mov	DWORD PTR 8+[esp+32], eax
$L90581:

; 1545 : 	{
; 1546 : 		// 增加一个光源
; 1547 : 		KSelfBreathLight *pLight = new KSelfBreathLight;

	push	52					; 00000034H
	call	??2@YAPAXI@Z				; operator new
	add	esp, 4
	test	eax, eax
	je	$L90582
	mov	ecx, eax
	call	??0KSelfBreathLight@@QAE@XZ		; KSelfBreathLight::KSelfBreathLight
	mov	esi, eax

; 1548 : 		if(pLight)

	test	esi, esi
	je	$L90582

; 1549 : 		{
; 1550 : 			// 保证nMaxRange大于nMinRange
; 1551 : 			if(pLights[i].nMaxRange >= pLights[i].nMinRange)

	mov	ecx, DWORD PTR [edi]
	mov	edx, DWORD PTR [edi-4]
	cmp	ecx, edx
	jl	SHORT $L90590

; 1552 : 				nMaxRange = pLights[i].nMaxRange, nMinRange = pLights[i].nMinRange;

	mov	eax, ecx
	mov	ecx, edx
	mov	DWORD PTR _nMaxRange$[esp+32], eax

; 1553 : 			else

	jmp	SHORT $L90591
$L90590:

; 1554 : 				nMaxRange = pLights[i].nMinRange, nMinRange = pLights[i].nMaxRange;

	mov	eax, edx
	mov	DWORD PTR _nMaxRange$[esp+32], eax
$L90591:

; 1555 : 			// 半径为负值，忽略这个光源
; 1556 : 			if(nMinRange < 0)

	test	ecx, ecx
	jl	$L90582

; 1557 : 			{
; 1558 : 				_ASSERT(0);
; 1559 : 				continue;
; 1560 : 			}
; 1561 : 
; 1562 : 			nMinRange = nMaxRange - 8;
; 1563 : 
; 1564 : 			pLight->m_dwColor = pLights[i].dwColor;

	mov	edx, DWORD PTR [edi-8]

; 1565 : 			pLight->m_oPosition.nX = pLights[i].oPos.x;
; 1566 : 			pLight->m_oPosition.nY = pLights[i].oPos.y;
; 1567 : 			pLight->m_oPosition.nZ = pLights[i].oPos.z;
; 1568 : 			pLight->m_nRadius = nMinRange + g_Random(nMaxRange - nMinRange);

	mov	ebx, DWORD PTR __imp_?g_Random@@YAII@Z
	mov	DWORD PTR [esi+20], edx
	mov	ecx, DWORD PTR [edi-20]
	mov	DWORD PTR [esi+8], ecx
	mov	edx, DWORD PTR [edi-16]
	lea	ebp, DWORD PTR [eax-8]
	mov	DWORD PTR [esi+12], edx
	mov	ecx, DWORD PTR [edi-12]
	sub	eax, ebp
	push	eax
	mov	DWORD PTR _nMinRange$[esp+40], ebp
	mov	DWORD PTR [esi+16], ecx
	call	ebx
	add	eax, ebp

; 1569 : 			pLight->fRadius = (float)(pLight->m_nRadius);
; 1570 : 			pLight->m_pParent = NULL;

	xor	ebp, ebp
	mov	DWORD PTR -16+[esp+40], eax

; 1571 : 			pLight->fMaxRange = (float)nMaxRange;
; 1572 : 			pLight->fMinRange = (float)nMinRange;
; 1573 : 			pLight->fCycle = 100 * 0.875f + g_Random(60 / 4);

	push	15					; 0000000fH
	fild	DWORD PTR -16+[esp+44]
	mov	DWORD PTR [esi+24], eax
	mov	DWORD PTR [esi+4], ebp
	fstp	DWORD PTR [esi+36]
	fild	DWORD PTR _nMaxRange$[esp+40]
	fstp	DWORD PTR [esi+32]
	fild	DWORD PTR _nMinRange$[esp+44]
	fstp	DWORD PTR [esi+28]
	call	ebx
	mov	DWORD PTR -8+[esp+44], eax
	mov	DWORD PTR -8+[esp+48], ebp
	fild	QWORD PTR -8+[esp+44]

; 1574 : 			m_LightList.push_back(pLight);

	mov	edx, DWORD PTR _this$[esp+44]
	push	12					; 0000000cH
	fadd	DWORD PTR __real@4@4005af00000000000000
	fstp	DWORD PTR [esi+40]
	mov	ebp, DWORD PTR [edx+92276]
	mov	ebx, DWORD PTR [ebp+4]
	call	??2@YAPAXI@Z				; operator new
	add	esp, 12					; 0000000cH
	mov	ecx, ebp
	test	ebp, ebp
	jne	SHORT $L93121
	mov	ecx, eax
$L93121:
	test	ebx, ebx
	mov	DWORD PTR [eax], ecx
	jne	SHORT $L93123
	mov	ebx, eax
$L93123:
	mov	DWORD PTR [eax+4], ebx
	mov	DWORD PTR [ebp+4], eax
	mov	ecx, DWORD PTR [eax+4]
	mov	DWORD PTR [ecx], eax
	add	eax, 8
	test	eax, eax
	je	SHORT $L93148
	mov	DWORD PTR [eax], esi
$L93148:
	mov	eax, DWORD PTR _this$[esp+36]
	inc	DWORD PTR [eax+92280]
$L90582:
	mov	eax, DWORD PTR 8+[esp+32]
	add	edi, 28					; 0000001cH
	dec	eax
	mov	DWORD PTR 8+[esp+32], eax
	jne	$L90581
	pop	edi
	pop	esi
	pop	ebp
	pop	ebx
$L90583:

; 1575 : 		}
; 1576 : 	}
; 1577 : }

	add	esp, 20					; 00000014H
	ret	8
?AddBuildinLight@KIpoTree@@QAEXPAUKBuildInLightInfo@@H@Z ENDP ; KIpoTree::AddBuildinLight
_TEXT	ENDS
PUBLIC	?EnableBioLights@KIpoTree@@QAEX_N@Z		; KIpoTree::EnableBioLights
;	COMDAT ?EnableBioLights@KIpoTree@@QAEX_N@Z
_TEXT	SEGMENT
_bEnable$ = 8
?EnableBioLights@KIpoTree@@QAEX_N@Z PROC NEAR		; KIpoTree::EnableBioLights, COMDAT

; 1581 : 	m_bProcessBioLights = bEnable;

	mov	al, BYTE PTR _bEnable$[esp-4]
	push	esi
	push	edi
	mov	edi, ecx

; 1582 : 
; 1583 : 	if(!bEnable)

	test	al, al
	mov	BYTE PTR [edi+89], al
	jne	SHORT $L90609

; 1584 : 	{
; 1585 : 		//清除所有内建对象的光源
; 1586 : 		list<KLightBase*>::iterator i;
; 1587 : 		for (i = m_LightList.begin(); i != m_LightList.end(); )

	mov	eax, DWORD PTR [edi+92276]
	mov	esi, DWORD PTR [eax]
	cmp	esi, eax
	je	SHORT $L90609
	push	ebx
$L90608:

; 1588 : 		{
; 1589 : 			if((*i)->m_pParent == NULL)

	mov	eax, DWORD PTR [esi+8]
	mov	ecx, DWORD PTR [eax+4]
	test	ecx, ecx
	jne	SHORT $L90610

; 1590 : 			{
; 1591 : 				delete (*i);

	push	eax
	call	??3@YAXPAX@Z				; operator delete

; 1592 : 				i = m_LightList.erase(i);

	mov	eax, DWORD PTR [esi+4]
	mov	ebx, DWORD PTR [esi]
	push	esi
	mov	DWORD PTR [eax], ebx
	mov	ecx, DWORD PTR [esi]
	mov	edx, DWORD PTR [esi+4]
	mov	DWORD PTR [ecx+4], edx
	call	??3@YAXPAX@Z				; operator delete
	mov	eax, DWORD PTR [edi+92280]
	add	esp, 8
	dec	eax
	mov	esi, ebx
	mov	DWORD PTR [edi+92280], eax

; 1593 : 				continue;

	jmp	SHORT $L93346
$L90610:

; 1594 : 			}
; 1595 : 			++i;

	mov	esi, DWORD PTR [esi]
$L93346:
	cmp	esi, DWORD PTR [edi+92276]
	jne	SHORT $L90608
	pop	ebx
$L90609:
	pop	edi
	pop	esi

; 1596 : 		}
; 1597 : 	}
; 1598 : }

	ret	4
?EnableBioLights@KIpoTree@@QAEX_N@Z ENDP		; KIpoTree::EnableBioLights
_TEXT	ENDS
PUBLIC	?EnableDynamicLights@KIpoTree@@QAEX_N@Z		; KIpoTree::EnableDynamicLights
;	COMDAT ?EnableDynamicLights@KIpoTree@@QAEX_N@Z
_TEXT	SEGMENT
_bEnable$ = 8
?EnableDynamicLights@KIpoTree@@QAEX_N@Z PROC NEAR	; KIpoTree::EnableDynamicLights, COMDAT

; 1602 : 	m_bDynamicLighting = bEnable;

	mov	al, BYTE PTR _bEnable$[esp-4]
	mov	BYTE PTR [ecx+90], al

; 1603 : }

	ret	4
?EnableDynamicLights@KIpoTree@@QAEX_N@Z ENDP		; KIpoTree::EnableDynamicLights
_TEXT	ENDS
;	COMDAT ??1?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QAE@XZ
_TEXT	SEGMENT
??1?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QAE@XZ PROC NEAR ; std::list<KLightBase *,std::allocator<KLightBase *> >::~list<KLightBase *,std::allocator<KLightBase *> >, COMDAT

; 151  : 		{erase(begin(), end());

	push	ebx
	push	esi
	push	edi
	mov	edi, ecx
	mov	ebx, DWORD PTR [edi+4]
	mov	esi, DWORD PTR [ebx]
	cmp	esi, ebx
	je	SHORT $L93572
$L93571:
	mov	eax, esi
	mov	esi, DWORD PTR [esi]
	push	eax
	mov	ecx, DWORD PTR [eax+4]
	mov	edx, DWORD PTR [eax]
	mov	DWORD PTR [ecx], edx
	mov	ecx, DWORD PTR [eax]
	mov	edx, DWORD PTR [eax+4]
	mov	DWORD PTR [ecx+4], edx
	call	??3@YAXPAX@Z				; operator delete
	mov	ecx, DWORD PTR [edi+8]
	add	esp, 4
	dec	ecx
	cmp	esi, ebx
	mov	DWORD PTR [edi+8], ecx
	jne	SHORT $L93571
$L93572:

; 152  : 		_Freenode(_Head);

	mov	eax, DWORD PTR [edi+4]
	push	eax
	call	??3@YAXPAX@Z				; operator delete
	add	esp, 4

; 153  : 		_Head = 0, _Size = 0; }

	xor	eax, eax
	mov	DWORD PTR [edi+4], eax
	mov	DWORD PTR [edi+8], eax
	pop	edi
	pop	esi
	pop	ebx
	ret	0
??1?$list@PAVKLightBase@@V?$allocator@PAVKLightBase@@@std@@@std@@QAE@XZ ENDP ; std::list<KLightBase *,std::allocator<KLightBase *> >::~list<KLightBase *,std::allocator<KLightBase *> >
_TEXT	ENDS
END
