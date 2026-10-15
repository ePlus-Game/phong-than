#ifndef PHONGTHAN_TRAP_SCRIPT_H
#define PHONGTHAN_TRAP_SCRIPT_H

// Region_S town portal cells retain the original VNG script ID. Its logical
// filename is unknown, so loading exit_truyen_tong.lua alone cannot register it.
inline const char* PhongThanTrapFallback(unsigned long scriptId)
{
    return scriptId == 0xCE741D0EUL
        ? "\\script\\phongthan\\npc_fix\\exit_truyen_tong.lua" : 0;
}

#endif
