# Phong Thần Truyền Kỳ — Test matrix

See [MASTER_ROADMAP.md](MASTER_ROADMAP.md) for milestone priorities, dependencies and release gates.

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
- `windows-native-modules.yml` compiles and links `LuaLibDll` and `Engine` from a fresh external copy on GitHub-hosted Windows (MSVC x86), validating PE32/i386 and hashes for newly built Client/Server DLL outputs. [PASS run #38520540848](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38520540848). Engine still uses historical `Lib/release` libraries; this is not all-dependency source rebuild or a playable runtime test.
- `windows-core-modules.yml` adds `Common`, `ExpandPackageStaticLib`, `FilterTextStatic`, `CoreServer`, `CoreClient` to the fresh x86 build sequence. [7/7 PASS run #38523254976](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38523254976), checking new PE32 DLL and COFF LIB signatures with SHA-256. Legacy static dependencies remain; neither full 22-binary build nor native game runtime has been tested.
- `windows-server-modules.yml` compiles/links all 5 server executables and ten dependencies in one fresh x86 Windows workflow. [15/15 PASS run #38526607624](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38526607624), with PE32 EXE/DLL and COFF hashes. AccountServer compatibility fixes are applied only to an isolated source copy; no server process or game state was executed.
- `windows-client-modules.yml` compiles/links `Game.exe`, `Represent2.dll`, `Represent3.dll` and 10 dependencies in an isolated hosted Windows x86 workspace. [13/13 PASS run #38530141589](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38530141589), PE32/COFF plus SHA-256. No game/client process or player data was executed; P4/P5 remain pending.
- `windows-combined-build.yml` builds 19 C++ projects in one clean Windows x86 workspace and verifies all 22 emitted role-specific EXE/DLL binaries. [PASS run #38531158753](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38531158753). [Import audit PASS run #38546154123](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38546154123) statically inspected normal and delay-load imports of 22/22 outputs, with no incorrect project-local role, and recorded 4 external DLL names not yet verified on a Windows runtime. Follow the manual VM acceptance checklist in [M2_ISOLATED_RUNTIME_UAT.md](M2_ISOLATED_RUNTIME_UAT.md). Only copied source and metadata are used.
- Older PowerShell and native test programs under `PhongThanSource/Tests/` are **not** all executed by these GitHub workflows.
- `tests/test_reward_pet_overlay.py` is included in `unittest discover`; do **not** run it twice in the same job.

## Read-only historical runtime log diagnostics

The checked-in sample logs are **historical** and can contain multiple repeated
attempts. A count is not an exact number of distinct broken skills/scripts.
Use a **copy** of logs generated from the same isolated test run:

\`\`\`bash
python tools/inspect_runtime_diagnostics.py \
  --client-script-registry /test/Client/script_registry_diag.log \
  --server-script-registry /test/Server/script_registry_diag.log \
  --client-skill-log /test/Client/skill_loader_diag.log \
  --server-skill-log /test/Server/skill_loader_diag.log
\`\`\`

Exit code 2 flags missing evidence, a malformed registry or reported failures.
The JSON output contains aggregated counts/skill ID and height only; no player
names or raw log lines. Do **not** use this tool to change script registry
capacity or auto-replace skill data without checking PAK and runtime loader
semantics. The historic staging logs currently include client
\`loaded=5 failed=4725 capacity=5\`, server \`loaded=5293 failed=68 capacity=10000\`
and both found/missing entries for skill \`1973\`; these are investigation
signals, **not** confirmation that the current run failed.

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
