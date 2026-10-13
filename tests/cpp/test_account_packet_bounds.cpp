#include "../../overlays/legacy/AccountPacketBounds.h"
#include <assert.h>
#include <stddef.h>
int main()
{
    const size_t min = 20;
    const size_t max = 1024U * 1024U;
    assert(PtRecovery::IsPacketLengthWithinBounds(min,min,max));
    assert(PtRecovery::IsPacketLengthWithinBounds(max,min,max));
    assert(PtRecovery::IsPacketLengthWithinBounds(min+1,min,max));
    assert(!PtRecovery::IsPacketLengthWithinBounds(0,min,max));
    assert(!PtRecovery::IsPacketLengthWithinBounds(min-1,min,max));
    assert(!PtRecovery::IsPacketLengthWithinBounds(max+1,min,max));
    assert(!PtRecovery::IsPacketLengthWithinBounds((size_t)-1,min,max));
    assert(!PtRecovery::IsPacketLengthWithinBounds(10,0,10));
    assert(!PtRecovery::IsPacketLengthWithinBounds(10,11,10));
    assert(PtRecovery::IsPacketLengthWithinBounds(8,8,260));
    assert(PtRecovery::IsPacketLengthWithinBounds(260,8,260));
    assert(!PtRecovery::IsPacketLengthWithinBounds(7,8,260));
    assert(!PtRecovery::IsPacketLengthWithinBounds(261,8,260));
    return 0;
}
