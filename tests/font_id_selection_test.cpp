#include "../PhongThanSource/Sources/Represent/Represent2/FontIdSelection.h"
#include <stdio.h>
static int failures = 0;
static void check(int expected, int actual, const char* name) {
    if (expected != actual) { ++failures; printf("FAIL %s: %d != %d\n",name,actual,expected); }
}
int main() {
    const int ids[] = {14,16,18,0,0,0};
    const unsigned char loaded[] = {1,1,1,0,0,0};
    const unsigned char empty[] = {0,0,0,0,0,0};
    check(0,PT_SelectLoadedFont(14,ids,loaded,6),"exact 14");
    check(1,PT_SelectLoadedFont(16,ids,loaded,6),"exact 16");
    check(2,PT_SelectLoadedFont(18,ids,loaded,6),"exact 18");
    check(0,PT_SelectLoadedFont(10,ids,loaded,6),"legacy 10");
    check(0,PT_SelectLoadedFont(12,ids,loaded,6),"legacy 12");
    check(0,PT_SelectLoadedFont(13,ids,loaded,6),"legacy 13");
    check(0,PT_SelectLoadedFont(15,ids,loaded,6),"tie");
    check(1,PT_SelectLoadedFont(17,ids,loaded,6),"tie 17");
    check(2,PT_SelectLoadedFont(30,ids,loaded,6),"nearest 30");
    check(-1,PT_SelectLoadedFont(14,ids,empty,6),"empty");
    check(-1,PT_SelectLoadedFont(0,ids,loaded,6),"zero");
    check(-1,PT_SelectLoadedFont(-1,ids,loaded,6),"negative");
    check(-1,PT_SelectLoadedFont(14,0,loaded,6),"null ids");
    check(-1,PT_SelectLoadedFont(14,ids,0,6),"null flags");
    check(-1,PT_SelectLoadedFont(14,ids,loaded,0),"zero count");
    const unsigned char only18[] = {0,0,1,0,0,0};
    check(2,PT_SelectLoadedFont(14,ids,only18,6),"only one loaded");
    printf("%s FontIdSelection (%d errors)\n",failures?"FAIL":"PASS",failures);
    return failures != 0;
}
