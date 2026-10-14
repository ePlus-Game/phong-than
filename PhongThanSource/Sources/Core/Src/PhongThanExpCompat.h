#ifndef PHONGTHAN_EXP_COMPAT_H
#define PHONGTHAN_EXP_COMPAT_H

// Bounded level EXP and arithmetic for the legacy 32-bit player/save/wire ABI.
// Do not re-encode the original CP936/TCVN3 settings files or widen save structs.
#include <limits.h>
#include <string.h>

inline int PhongThanClampSignedExp(long long value)
{
    if (value > INT_MAX) return INT_MAX;
    if (value < -static_cast<long long>(INT_MAX)) return -INT_MAX;
    return static_cast<int>(value);
}

inline int PhongThanClampPositiveExp(long long value)
{
    if (value <= 0) return 1;
    if (value > INT_MAX) return INT_MAX;
    return static_cast<int>(value);
}

inline bool PhongThanParseNonnegativeInt32(const char* value, int* output)
{
    if (!value || !*value || !output) return false;
    long long number = 0;
    for (const char* p = value; *p; ++p)
    {
        if (*p < '0' || *p > '9') return false;
        number = number * 10 + (*p - '0');
        if (number > INT_MAX) return false;
    }
    *output = static_cast<int>(number);
    return true;
}

// Bundled level_exp.txt accidentally repeats 5,300,556,000 for levels
// 131..200. That value cannot fit player EXP, save or protocol fields.
// Preserve levels 1..130, and supply an explicit bounded compatibility curve
// *only* when the known invalid placeholder is found in those exact rows.
// Starting at 530,055,600, increase by 20m per level plus 50k incremental
// growth. Level 200 costs 2,030,805,600 (< INT_MAX). This is a project
// compatibility rule, NOT an assertion about original VNG progression.
inline bool PhongThanParseBaseLevelExp(const char* value, int level, int* output)
{
    if (level >= 131 && level <= 200 &&
        value && strcmp(value, "5300556000") == 0 && output)
    {
        const long long offset = static_cast<long long>(level - 131);
        const long long exp = 530055600LL + offset * 20000000LL +
                              (offset * (offset + 1) / 2) * 50000LL;
        if (exp > INT_MAX) return false;
        *output = static_cast<int>(exp);
        return true;
    }
    return PhongThanParseNonnegativeInt32(value, output);
}

#endif
