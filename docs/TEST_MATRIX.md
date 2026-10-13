# Phong Thần Truyền Kỳ — Test matrix

This document distinguishes source verification from tests that actually execute a Windows x86 client/server. A green GitHub Actions badge is **not** evidence that the game is playable.

| Tier | Execution | Scope | Acceptance |
|---|---|---|---|
| 1. Source/tooling | Ubuntu PR CI | Python tools, original-byte patch contexts, C++98 helpers, source/quest data | All tests pass and no archive files are changed |
| 2. Windows preflight/build | Trusted manually dispatched Windows build runner | VS2022 x86/SDK, compiler and linker logs, output artifacts | Each selected project builds with no errors; SHA-256 reports saved |
| 3. Server smoke | Isolated local Windows VM | Five native services, world registration, ports, account DB, scripts | Fresh 102-map world-ready marker, every expected process healthy |
| 4. Game scenario | Isolated Windows VM with test account/save backup | Login, character, movement, map switch, item/quest/pet, logout and relogin | Explicit before/after state and no item/reward duplication |
| 5. Stability | Isolated Windows VM on a schedule | Restart cycles, 10+ clients, soak, memory and reconnect | No unexpected exit, save corruption, stuck session or regressions |

## Current automated coverage

- `legacy-source-audit.yml` invokes `python -m unittest discover -s tests -v`, two portable C++98 tests, a static build preflight, and produces a separately downloadable branding overlay.
- `quest-content-integrity.yml` validates selected quest assets, SHA-256 provenance, and contract fixtures only when quest-related files change.
- Older PowerShell and native test programs under `PhongThanSource/Tests/` are **not** all executed by these GitHub workflows.
- `tests/test_reward_pet_overlay.py` is included in `unittest discover`; do **not** run it twice in the same job.

## Execution safety

- Never build or run untrusted PR/fork code on an equipped self-hosted Windows game runner.
- Run native tests only with **copied** source/runtime, a test-only database and dummy player accounts; preserve original PAK and historical source.
- Do not auto-apply Lua overlays to live server and do not replay partially granted rewards.
- Do not upload account databases, player saves, passwords, production configs or full runtime logs as CI artifacts.
- An archive source file may have changed at the byte level even when a native build works; hash-sensitive source preservation is a separate gate.

## Focused commands

```bash
python -m compileall -q tools tests
python -m unittest discover -s tests -v
python tools/quest_content_audit.py --root .
```

```powershell
# Read-only preflight; does not compile or launch the game
.\tools\Build-PatchedGame.ps1 -WorkRoot 'D:\PT-Verify\Build-001' -Toolchain Modern -PreflightOnly
# Only on a Windows host with the required SDK, toolchain and disk capacity:
.\tools\Build-PatchedGame.ps1 -WorkRoot 'D:\PT-Verify\Build-001' -Toolchain Modern
```

Note: Build-PatchedGame refuses to overwrite a work folder. The real build must use a **fresh** WorkRoot, not a previously populated directory. Runtime acceptance and crash/reconnect scenarios require an isolated, explicitly configured test environment.
