# Windows client font restoration — staged work

## Scope / evidence

The client uses legacy bitmap fonts. Staged resources include
`Client/font/14.fnt`, `16.fnt`, `18.fnt`.
`UiBase.cpp` loads `FontList` IDs from the UI scheme, falls back to VNG
bitmap fonts and writes diagnostics to `ui_font_load.log`.

Before this change, `Represent2/KRepresentShell2.cpp::OutputText` used
the closest **loaded** font for IDs such as 10/12/13, but
`OutputVNText`, `OutputRichText` and `LocateRichText` did **not**.
They could silently omit strings, and rich-text click/offset calculation
could disagree with what was drawn.

## Phase 1: missing text because a font ID is absent — in PR

- Share one `FontIdSelection.h` resolver across all four Represent2 paths.
- Exact loaded font wins; otherwise use closest loaded font.
- Invalid ID, unloaded font table -> safe no-op / unchanged return value.
- Keep requested text size and existing .fnt files unchanged.
- Run Windows x86 C++ unit tests; inspect production build separately.

**Does not fix** incorrect Vietnamese glyphs, mis-decoded UTF-8,
TCVN3/VNI strings or outdated NPC data.

## Phase 2: incorrect glyphs / diacritics — next

- Reproduce separately on login labels, NPC dialogues, item names and chat.
- Identify each string's actual byte encoding and the renderer's index
  mapping before translating any text.
- Compare `KFont2::OutputText`, `KFontData`, the text renderer and
  source resources; avoid introducing UTF-8 without an explicit decoder.
- Add byte-exact fixtures for Vietnamese strings in the identified encoding.

## Phase 3: resource-specific defects

- Check `Ui` INI, Lua, `settings` and PAK sources for each affected
  screen, rather than mass conversion of the repository.
- Preserve original packed resources and legacy C++ byte encodings.
- Deploy changed binaries only to an isolated Windows test copy after
  matching the native binary/deployment manifest; NEVER overwrite an
  active server's DLL.

## Windows validation checklist

1. Inspect `Client/ui_font_load.log` for which font IDs/files loaded.
2. Test login screen labels, NPC dialogue, rich text and chat separately.
3. Check `WORLD_READY` independently before attempting real login.
4. Record a screenshot per reproduced area plus exact text expected and
   displayed. A passing C++ unit test is **not** proof that gameplay fonts
   are fully repaired.
