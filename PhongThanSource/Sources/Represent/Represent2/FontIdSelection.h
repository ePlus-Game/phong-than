// Font-id resolver shared by all Represent2 text entry points.
// Pure C++ and independent of the game's runtime/data encoding.
#ifndef PT_REPRESENT2_FONT_ID_SELECTION_H
#define PT_REPRESENT2_FONT_ID_SELECTION_H

inline int PT_SelectLoadedFont(int requestedId, const int* ids,
                               const unsigned char* loaded, int count)
{
    if (requestedId <= 0 || ids == 0 || loaded == 0 || count <= 0)
        return -1;

    // Exact loaded font must take precedence, regardless of table order.
    for (int i = 0; i < count; ++i)
        if (loaded[i] && ids[i] == requestedId)
            return i;

    int closest = -1;
    int closestDistance = 0x7fffffff;
    for (int i = 0; i < count; ++i)
    {
        if (!loaded[i] || ids[i] <= 0)
            continue;
        const int difference = (ids[i] >= requestedId)
            ? ids[i] - requestedId : requestedId - ids[i];
        if (difference < closestDistance)
        {
            closest = i;
            closestDistance = difference;
        }
    }
    return closest;
}
#endif
