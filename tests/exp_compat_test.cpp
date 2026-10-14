#include "../PhongThanSource/Sources/Core/Src/PhongThanExpCompat.h"
#include <assert.h>
#include <limits.h>
#include <stdio.h>

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
    puts("EXP compatibility policy: PASS");
    return 0;
}
