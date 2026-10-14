// Fallback to a system arrow if a legacy .cur is absent or unreadable.
#ifndef PT_UI_CURSOR_FALLBACK_H
#define PT_UI_CURSOR_FALLBACK_H
#include <windows.h>
inline HCURSOR PT_UsableCursor(HCURSOR preferred)
{
    return preferred ? preferred : ::LoadCursor(NULL, IDC_ARROW);
}
inline bool PT_CursorVisibilityChanged(int oldShow, int newShow)
{
    return (oldShow != 0) != (newShow != 0);
}
#endif
