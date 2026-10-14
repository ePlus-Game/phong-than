#include "../PhongThanSource/Sources/Represent/iRepresent/Font/FontTextLineBreak.h"
#include <stdio.h>
#include <string.h>

static int failures = 0;
static void check(int actual, int expected, const char* label)
{
    if (actual != expected) { ++failures; printf("FAIL %s: %d instead of %d\n", label,actual,expected); }
}
static void countText(const char* s, int* glyphs, int* lines)
{
    const unsigned char* bytes = (const unsigned char*)s;
    const int n = (int)strlen(s);
    *glyphs = 0; *lines = 0;
    for (int i=0;i<n;)
    {
        const int next = PT_FontAfterLineBreak(bytes,n,i);
        if (next > i) { ++*lines; i=next; }
        else { ++*glyphs; ++i; }
    }
}
int main()
{
    const unsigned char crlf[]={'A','\r','\n','B'};
    check(PT_FontAfterLineBreak(crlf,4,1),3,"CRLF consumed together");
    check(PT_FontAfterLineBreak(crlf,4,2),3,"LF alone");
    check(PT_FontAfterLineBreak(crlf,4,0),0,"ASCII glyph untouched");
    check(PT_FontAfterLineBreak(crlf,4,3),3,"last glyph untouched");
    check(PT_FontAfterLineBreak(crlf,4,4),4,"no out-of-bounds");
    check(PT_FontAfterLineBreak(crlf,4,-1),-1,"negative index");
    check(PT_FontAfterLineBreak(0,4,1),1,"null buffer");
    const unsigned char cr[]={'a','\r','b'};
    check(PT_FontAfterLineBreak(cr,3,1),2,"single CR");
    int glyphs=0,lines=0;
    countText("A\r\nB\nC\rD",&glyphs,&lines);
    check(glyphs,4,"only printable glyphs");
    check(lines,3,"three logical newlines");
    countText("Hello",&glyphs,&lines);
    check(glyphs,5,"normal text unchanged");
    check(lines,0,"no extra line breaks");
    countText("\n\r\n",&glyphs,&lines);
    check(glyphs,0,"line breaks are not rendered");
    check(lines,2,"two breaks, not three");
    printf("%s font newline test\n",failures?"FAIL":"PASS");
    return failures?1:0;
}
