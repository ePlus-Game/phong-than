#include "../PhongThanSource/Sources/GameClient/Ui/Elem/CursorFallback.h"
#include <stdio.h>
static int failures=0;
static void check(bool condition,const char* message)
{
    if (!condition) { ++failures; printf("FAIL %s\n",message); }
}
int main()
{
    HCURSOR arrow=::LoadCursor(NULL,IDC_ARROW);
    check(arrow!=NULL,"Windows standard cursor available");
    check(PT_UsableCursor(NULL)==arrow,"missing custom cursor falls back to arrow");
    check(PT_UsableCursor(arrow)==arrow,"existing cursor retained");
    check(!PT_CursorVisibilityChanged(1,1),"repeated show idempotent");
    check(!PT_CursorVisibilityChanged(0,0),"repeated hide idempotent");
    check(PT_CursorVisibilityChanged(-1,0),"nonzero negative is visible; changing to zero hides");
    check(PT_CursorVisibilityChanged(0,1),"hidden to visible");
    check(PT_CursorVisibilityChanged(1,0),"visible to hidden");
    printf("%s cursor fallback tests (%d failures)\n",failures?"FAIL":"PASS",failures);
    return failures!=0;
}
