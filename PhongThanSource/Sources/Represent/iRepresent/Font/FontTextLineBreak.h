// Interpret CR, LF and CRLF as line breaks, never as bitmap glyphs.
// This byte-level helper is for the legacy single-byte bitmap renderer.
// It intentionally does NOT attempt UTF-8, VNI or TCVN3 conversion.
#ifndef PT_FONT_TEXT_LINE_BREAK_H
#define PT_FONT_TEXT_LINE_BREAK_H
inline int PT_FontAfterLineBreak(const unsigned char* bytes, int length, int start)
{
    if (!bytes || start < 0 || start >= length)
        return start;
    if (bytes[start] == '\r')
    {
        if (start + 1 < length && bytes[start + 1] == '\n')
            return start + 2;
        return start + 1;
    }
    if (bytes[start] == '\n')
        return start + 1;
    return start;
}
#endif
