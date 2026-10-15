#include <windows.h>
#include <stdio.h>
#include <string.h>
#include "../../Sources/Core/Src/PhongThanTrapScript.h"

struct lua_State;
int main(int argc, char** argv)
{
    if (argc != 4) return 2;
    const char* path = PhongThanTrapFallback(0xCE741D0EUL);
    if (!path || strcmp(path, "\\script\\phongthan\\npc_fix\\exit_truyen_tong.lua")) return 3;
    if (PhongThanTrapFallback(0) || PhongThanTrapFallback(0xCA147D6CUL)) return 4;
    HMODULE dll = LoadLibraryA(argv[1]);
    if (!dll) return 5;
    typedef lua_State* (__cdecl *Open)(int);
    typedef void (__cdecl *Close)(lua_State*);
    typedef int (__cdecl *Run)(lua_State*, const char*);
    Open open = (Open)GetProcAddress(dll, "lua_open");
    Close close = (Close)GetProcAddress(dll, "lua_close");
    Run file = (Run)GetProcAddress(dll, "lua_dofile");
    Run text = (Run)GetProcAddress(dll, "lua_dostring");
    Close base = (Close)GetProcAddress(dll, "lua_baselibopen");
    if (!open || !close || !file || !text || !base) return 6;
    lua_State* L = open(0);
    if (!L) return 7;
    base(L);
    int result = text(L, "function Include(p) end");
    if (!result) result = file(L, argv[2]); // Actual shipped portal script.
    if (!result) result = file(L, argv[3]); // Mock only game/OS boundaries.
    close(L);
    FreeLibrary(dll);
    if (result) return 8;
    puts("PASS: town portal trap mapping and Lua 4 transfer/payment regression");
    return 0;
}
