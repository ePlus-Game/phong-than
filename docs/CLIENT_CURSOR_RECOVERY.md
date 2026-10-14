# Client cursor recovery — invisible pointer on Windows

## Confirmed issue in source

The shipped `PhongThanRuntime-Staging/Client/Ui/ui3/UiPubLicSetting.ini`
references `\\Spr\\Ui3\\鼠标\\*.cur`. The staging checkout does not contain
that directory; the only separately listed cursor file is
`Spr/Ui4/Êó±ê/npcfor2000.cur`. Some packed PAK builds may contain cursor
resources, so the absence of loose assets does not imply every player will
experience the failure.

The hardware cursor path in `Ui/Elem/UiCursor.cpp` previously called
`SetCursor(m_CursorImages[active])` even if `KUiLoadCursor` failed, when
the slot was still NULL. `SetCursor(NULL)` hides the Windows pointer.
Another problem was that repeated `Show(true)`/`Show(false)` calls
always changed Win32's display counter, even when there was no state change.

## Fix

- When the custom `.cur` load fails, use `LoadCursor(NULL, IDC_ARROW)`.
  Do not pass NULL to the hardware cursor.
- Apply the same fallback when switching/restoring cursor indexes.
- Make `KUiCursor::Show` avoid repeatedly incrementing/decrementing the
  Windows cursor display count for an unchanged desired state.
- Append missing custom cursor file paths to `Client/ui_cursor_load.log`
  to help determine which `CursorList` entries need to be restored.

This preserves game input events, PAK resources, SQL databases and server
processes. It does not replace custom game-themed cursors with invented files.

## Deployment / verification

Source changes require rebuilding and using **a compatible new Game.exe**
(the cursor implementation is part of the native Client), not merely
`git pull`. Use an isolated test copy of the Client with known-compatible
native binaries. **Do not overwrite the running game's DLLs or Client binary**
with artifacts built against different dependency versions.

After starting the test Client:
1. Move the mouse over the login, character selection, and game windows.
2. Confirm at least the standard arrow remains visible.
3. Confirm no missing cursor slot leads to a blank pointer when entering
   NPC/shop interactions.
4. Inspect `ui_cursor_load.log` for unavailable custom cursor paths.
5. Test show/hide transitions, window switching and exiting the game.

A passing Windows x86 unit test and Client build do **not** prove the issue
has been resolved on the user's current Windows runtime until tested there.
