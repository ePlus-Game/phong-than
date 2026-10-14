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

## Phase 2B: verified one-byte recovery in `UiStatus.ini`

`KIniFile::Load` reads the original INI bytes and `GetString` passes those
bytes directly to `KFont2::OutputText` (one font slot per byte; no UTF-8
decoder). The status UI originally contained **UTF-8-expanded forms of
legacy TCVN3/ABC byte codes**. Examples from the exact source:

| UI label | Wrong UTF-8 byte sequence | One-byte bitmap input |
| --- | --- | --- |
| `Vò khÝ` | `56 C3 B2 20 6B 68 C3 9D` | `56 F2 20 6B 68 DD` |
| `Ma ph¸p` | `4D 61 20 70 68 C2 B8 70` | `4D 61 20 70 68 B8 70` |
| `TËp trung` | `54 C3 8B 70 20 74 72 75 6E 67` | `54 CB 70 20 74 72 75 6E 67` |

This PR restores **only 27 `Text=` / `Tip=` fields** in the character-status
section (original lines 248–448) of `PhongThanRuntime-Staging/Client/Ui/ui3/UiStatus.ini`.
Every restored high byte was checked against the original VNG `14.fnt` bitmap
slot table (all mapped). The rest of the file, including unrelated UI and
unsupported code points, remains byte-for-byte unchanged.

The repaired bytes must reach the client from the actual runtime resource
search path; an older packed PAK entry may take precedence over the loose INI.
**CI validates source bytes, not the final in-game appearance.** Never update
live Client DLLs or PAKs solely to test this change. Stage in a separate Windows
test copy and compare actual character sheet screenshots.
