#include "../PhongThanSource/Sources/Core/Src/PhongThanExpCompat.h"
#include <assert.h>
#include <limits.h>
#include <stdio.h>
#include <fstream>
#include <sstream>
#include <string>

int main()
{
    int exp = -1;
    assert(PhongThanParseBaseLevelExp("496166400", 130, &exp) && exp == 496166400);
    assert(PhongThanParseBaseLevelExp("5300556000", 131, &exp) && exp == 530055600);
    assert(PhongThanParseBaseLevelExp("5300556000", 132, &exp) && exp == 550105600);
    assert(PhongThanParseBaseLevelExp("5300556000", 200, &exp) && exp == 2030805600);
    assert(!PhongThanParseBaseLevelExp("5300556000", 130, &exp));
    assert(!PhongThanParseBaseLevelExp("999999999999999999999999", 150, &exp));
    assert(!PhongThanParseBaseLevelExp("-3", 150, &exp));
    assert(!PhongThanParseBaseLevelExp("123abc", 150, &exp));
    assert(PhongThanParseNonnegativeInt32("0", &exp) && exp == 0);
    assert(PhongThanParseNonnegativeInt32("2147483647", &exp) && exp == INT_MAX);
    assert(!PhongThanParseNonnegativeInt32("2147483648", &exp));
    assert(PhongThanClampSignedExp(static_cast<long long>(INT_MAX) + 5000) == INT_MAX);
    assert(PhongThanClampSignedExp(-static_cast<long long>(INT_MAX) - 5000) == -INT_MAX);
    assert(PhongThanClampPositiveExp(static_cast<long long>(INT_MAX) + 100) == INT_MAX);
    assert(PhongThanClampPositiveExp(0) == 1);

    // Parse the actual bundled CP936 tables (numeric rows are plain ASCII)
    // with the same compatibility policy as the player engine.
    const char* tables[] = {
        "PhongThanRuntime-Staging/Server/settings/npc/player/level_exp.txt",
        "PhongThanRuntime-Staging/Client/settings/npc/player/level_exp.txt"
    };
    int reference[200] = {};
    for (int table = 0; table < 2; ++table)
    {
        std::ifstream input(tables[table], std::ios::binary);
        assert(input.good());
        std::string row;
        std::getline(input, row); // legacy header
        int count = 0;
        int previous = -1;
        while (std::getline(input, row))
        {
            if (row.empty()) continue;
            std::istringstream record(row);
            int level = 0;
            std::string raw_exp;
            assert((record >> level >> raw_exp));
            assert(level == count + 1 && level <= 200);
            int safe = -1;
            assert(PhongThanParseBaseLevelExp(raw_exp.c_str(), level, &safe));
            assert(safe > previous && safe > 0 && safe <= INT_MAX);
            if (table == 1) assert(reference[count] == safe);
            else reference[count] = safe;
            previous = safe;
            ++count;
        }
        assert(count == 200);
    }
    puts("EXP compatibility policy and 200 original data rows: PASS");
    return 0;
}
