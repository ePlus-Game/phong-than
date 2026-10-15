// -------------------------------------------------------------------------
//	文件名		：	UiMsgSel.h
//	创建者		：	Wooy(Wu yue)
//	创建时间	：	2003-1-6
//	功能描述	：	带滚动条的消息选择
// -------------------------------------------------------------------------
#include "KWin32.h"
#include "KIniFile.h"
#include "../Elem/WndMessage.h"
#include "../Elem/WndMessageListBox.h"
#include "../Elem/Wnds.h"
#include "UiMsgSel.h"
#include "../../../engine/src/KDebug.h"
#include "../../../core/src/coreshell.h"
#include "../../../core/src/GameDataDef.h"
#include "../../../engine/src/kstrbase.h"
#include "../UiBase.h"
#include "../UiSoundSetting.h"

extern iCoreShell *g_pCoreShell;

#define    SCHEME_INI    "UiMsgSel.ini"
#define    SCHEME_INIP    "UiMsgSelPic.ini"

KUiMsgSel *KUiMsgSel::m_pSelf = NULL;


KUiMsgSel::KUiMsgSel() {
    m_uLeftTime = 0;
    m_bAutoUp = false;
    m_bAutoDown = false;
    m_uLastScrollTime = 0;
    memset(m_szPic, 0, sizeof(m_szPic));
}

KUiMsgSel::~KUiMsgSel() {
}

//--------------------------------------------------------------------------
//	功能：打开窗口，返回唯一的一个类对象实例
//--------------------------------------------------------------------------
KUiMsgSel *KUiMsgSel::OpenWindow(KUiQuestionAndAnswer *pQAA, KUiImage *pPic) {
    if (!pQAA || pQAA->AnswerCount < 0 || pQAA->AnswerCount > MAX_ANSWERNUM)
        return NULL;
    if (m_pSelf == NULL) {
        m_pSelf = new KUiMsgSel;
        if (m_pSelf && !m_pSelf->Initialize(pPic)) {
            delete m_pSelf;
            m_pSelf = NULL;
            return NULL;
        }
    }
    if (m_pSelf) {
        UiSoundPlay(UI_SI_WND_OPENCLOSE);
        m_pSelf->BringToTop();
        m_pSelf->Show(pQAA);
    }
    return m_pSelf;
}

//--------------------------------------------------------------------------
//	功能：关闭销毁窗口
//--------------------------------------------------------------------------
void KUiMsgSel::CloseWindow(bool bDestroy) {
    if (m_pSelf) {
        m_pSelf->m_bAutoUp = false;
        m_pSelf->m_bAutoDown = false;

        Wnd_ReleaseExclusive((KWndWindow *) m_pSelf);
        if (bDestroy) {
            m_pSelf->Destroy();
            m_pSelf = NULL;
        } else
            m_pSelf->Hide();
    }
}


KUiMsgSel *KUiMsgSel::GetIfVisible() {
    if (m_pSelf && m_pSelf->IsVisible())
        return m_pSelf;
    return NULL;
}

//--------------------------------------------------------------------------
//	功能：初始化
//--------------------------------------------------------------------------
int KUiMsgSel::Initialize(KUiImage *pPic) {
    if (pPic) {
        memcpy(&m_pPic, pPic, sizeof(KUiImage));
        if (m_pPic.Name[0])
            AddChild(&m_Image);
    } else
        memset(&m_pPic, 0, sizeof(KUiImage));
    AddChild(&m_MsgScrollList);
    AddChild(&m_MessageScroll);
    AddChild(&m_MessageList);
    AddChild(&m_CloseBtn);
    m_MessageList.SetScrollbar(&m_MessageScroll);
    char Scheme[256];
    g_UiBase.GetCurSchemePath(Scheme, 256);
    LoadScheme(Scheme);

    // Do not acquire exclusive input with an uninitialized dialog.
    if (m_Width <= 0 || m_Height <= 0 ||
        m_MsgScrollList.GetMessageListBox()->GetCapability() <= 0 ||
        m_MessageList.GetCapability() <= 0)
        return false;

    m_Style &= ~WND_S_VISIBLE;
    Wnd_AddWindow(this, WL_TOPMOST);
    return true;
}

//--------------------------------------------------------------------------
//	功能：载入窗口的界面方案
//--------------------------------------------------------------------------
void KUiMsgSel::LoadScheme(const char *pScheme) {
    if (m_pSelf == NULL)
        return;
    char Buff[128];
    KIniFile Ini;
    sprintf(Buff, "%s\\%s", pScheme, m_pSelf->m_pPic.Name[0] ? SCHEME_INIP : SCHEME_INI);
    if (Ini.Load(Buff)) {
        m_pSelf->Init(&Ini, "Main");
        m_pSelf->m_MsgScrollList.Init(&Ini, "Select");
        m_pSelf->m_MessageScroll.Init(&Ini, "MessageScroll");
        m_pSelf->m_MessageList.Init(&Ini, "MessageList");
        m_pSelf->m_CloseBtn.Init(&Ini, "CloseBtn");
        int nCloseWidth = 0, nCloseHeight = 0;
        Ini.GetInteger("CloseBtn", "Width", 0, &nCloseWidth);
        Ini.GetInteger("CloseBtn", "Height", 0, &nCloseHeight);
        if (nCloseWidth <= 0 || nCloseHeight <= 0)
            m_pSelf->m_CloseBtn.Hide();
        else
            m_pSelf->m_CloseBtn.Show();
        // TCVN3 bytes for the Vietnamese label: Kết thúc.
        m_pSelf->m_CloseBtn.SetText("K\xD5t th\xF3" "c");
    }
}

//--------------------------------------------------------------------------
//	功能：窗口消息函数
//--------------------------------------------------------------------------
int KUiMsgSel::WndProc(unsigned int uMsg, unsigned int uParam, int nParam) {
    int nRet = 0;
    switch (uMsg) {
        case WND_N_BUTTON_CLICK:
            if (uParam == (unsigned int)(KWndWindow*)&m_CloseBtn) {
                CloseWindow(true);
                return 1;
            }
            break;
        case WM_MOUSEMOVE:
        case WND_M_MOUSE_LEAVE:
            // Only explicit keyboard input or a hovered answer changes selection.
            m_bAutoUp = false;
            m_bAutoDown = false;
            break;
        case WND_N_LIST_ITEM_HIGHLIGHT:
            m_bAutoUp = false;
            m_bAutoDown = false;
            if (nParam >= 0) {
                m_MsgScrollList.GetMessageListBox()->SetCurSel(nParam);
                if (m_pPic.Name[0]) {
                    int nMWidth, nMHeight;
                    if (nParam < MAX_ANSWERNUM && m_szPic[nParam][0]) {
                        m_Image.SetImage(ISI_T_SPR, m_szPic[nParam], true);
                    } else {
                        m_Image.SetImage(ISI_T_SPR, m_pPic.Name, true);
                        m_Image.SetMaxFrame(m_pPic.Frame);
                    }
                    m_Image.GetSize(&nMWidth, &nMHeight);
                    m_Image.SetPosition(70 - nMWidth / 2, 70 - nMHeight / 2);
                }
            }
            break;
        case WND_N_LIST_ITEM_ACTIVE:
            m_bAutoUp = false;
            m_bAutoDown = false;
            if (nParam >= 0)
                OnClickMsg(nParam);
            break;
        case WND_N_SCORLLBAR_POS_CHANGED:
            if (uParam == (unsigned int) (KWndWindow *) &m_MessageScroll)
                m_MessageList.SetFirstShowLine(nParam);
            break;
        case WM_KEYDOWN:
            m_bAutoUp = false;
            m_bAutoDown = false;
            if (uParam == VK_RETURN) {
                nRet = m_MsgScrollList.GetMessageListBox()->GetCurSel();
                if (nRet >= 0)
                    OnClickMsg(nRet);
                nRet = 1;
            } else if (uParam == VK_UP) {
                ChangeCurSel(false);
                nRet = 1;
            } else if (uParam == VK_DOWN) {
                ChangeCurSel(true);
                nRet = 1;
            }
            break;
        default:
            nRet = KWndShowAnimate::WndProc(uMsg, uParam, nParam);
            break;
    }
    return nRet;
}

//--------------------------------------------------------------------------
//	功能：响应点击按钮
//--------------------------------------------------------------------------
void KUiMsgSel::OnClickMsg(int nMsg) {
    if (m_pSelf && nMsg >= 0 &&
        nMsg < m_pSelf->m_MsgScrollList.GetMessageListBox()->GetMsgCount()) {
        m_pSelf->CloseWindow(true);
        g_pCoreShell->OperationRequest(GOI_QUESTION_CHOOSE, 0, nMsg);
    }
}

void KUiMsgSel::ChangeCurSel(bool bNext) {
    int nRet = m_MsgScrollList.GetMessageListBox()->GetCurSel();
    if (bNext) {
        if (nRet < m_MsgScrollList.GetMessageListBox()->GetMsgCount() - 1)
            nRet = m_MsgScrollList.GetMessageListBox()->SetCurSel(nRet + 1);
    } else {
        if (nRet > 0)
            nRet = m_MsgScrollList.GetMessageListBox()->SetCurSel(nRet - 1);
    }
}

//--------------------------------------------------------------------------
//	功能：显示窗口
//--------------------------------------------------------------------------
void KUiMsgSel::Show(KUiQuestionAndAnswer *pQAA) {
    if (!pQAA || pQAA->AnswerCount < 0 || pQAA->AnswerCount > MAX_ANSWERNUM)
        return;
    {
        m_MsgScrollList.GetMessageListBox()->Clear();
        m_MessageList.Clear();
        m_MessageList.AddOneMessage(pQAA->Question, pQAA->QuestionLen);
        int i = 0;
        if (pQAA->AnswerCount <= 0 && !m_CloseBtn.IsVisible()) {
            m_MsgScrollList.GetMessageListBox()->AddOneMessage("K誸 th骳 i tho筰", -1);

        }
        if (pQAA->AnswerCount > 0) {
            for (i = 0; i < pQAA->AnswerCount; i++) {
                char *pAnswer = strstr(pQAA->Answer[i].AnswerText, "LINK:");
                if (m_pPic.Name[0] && pAnswer) {
                    g_StrCpyLen(m_szPic[i], pAnswer + 5, sizeof(m_szPic[i]));
                    *pAnswer = 0;
                    if (!m_MsgScrollList.GetMessageListBox()->AddOneMessage(pQAA->Answer[i].AnswerText,
                                                                            pQAA->Answer[i].AnswerLen))
                        m_MsgScrollList.GetMessageListBox()->AddOneMessage("[--K辌h b秐 x� l� l鏸--]", -1);
                } else {
                    m_szPic[i][0] = 0;
                    if (!m_MsgScrollList.GetMessageListBox()->AddOneMessage(pQAA->Answer[i].AnswerText,
                                                                            pQAA->Answer[i].AnswerLen))
                        m_MsgScrollList.GetMessageListBox()->AddOneMessage("[--K辌h b秐 x� l� l鏸--]", -1);
                }
            }
        }
    }
    KWndShowAnimate::Show();
    Wnd_SetExclusive((KWndWindow *) this);

    m_uLeftTime = pQAA->LeftTime;
    m_uLastScrollTime = IR_GetCurrentTime();
    m_bAutoUp = false;
    m_bAutoDown = false;

    if (m_pPic.Name[0]) {
        m_Image.SetImage(ISI_T_SPR, m_pPic.Name, true);
        int nMWidth, nMHeight;
        m_Image.GetSize(&nMWidth, &nMHeight);
        m_Image.SetPosition(70 - nMWidth / 2, 70 - nMHeight / 2);
        m_Image.SetMaxFrame(m_pPic.Frame);
    }
}

void KUiMsgSel::Breathe() {
    if (m_uLeftTime > 0) {
        m_uLeftTime--;
        if (m_uLeftTime == 0)
            CloseWindow(true);
    }

    if (m_Image.IsVisible())
        m_Image.NextFrame();

    if (m_bAutoUp) {
        if (IR_IsTimePassed(200, m_uLastScrollTime)) {
            ChangeCurSel(false);
            m_uLastScrollTime = IR_GetCurrentTime();
        }
    }

    if (m_bAutoDown) {
        if (IR_IsTimePassed(200, m_uLastScrollTime)) {
            ChangeCurSel(true);
            m_uLastScrollTime = IR_GetCurrentTime();
        }
    }
}
