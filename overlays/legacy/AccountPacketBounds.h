#ifndef PT_RECOVERY_ACCOUNT_PACKET_BOUNDS_H
#define PT_RECOVERY_ACCOUNT_PACKET_BOUNDS_H
// C++98; validate length before narrowing size_t or touching wire buffers.
// Installed only into the external working copy; original PT.zip is unmodified.
#include <stddef.h>
namespace PtRecovery {
inline bool IsPacketLengthWithinBounds(size_t length, size_t minimum, size_t maximum)
{
    return minimum != 0 && minimum <= maximum &&
           length >= minimum && length <= maximum;
}
}
#endif
