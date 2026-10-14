# M1 — Windows x86 build evidence and release gate

## Scope

`windows-x86-build.yml` builds **a fresh external copy** of `PhongThanSource`,
applies the existing reviewed legacy overlays, then invokes the MSVC v143 x86
builder. This step does **not** start the game, perform login, or update the
staging runtime.

The job is `workflow_dispatch` only on `main`; it requires confirmation and
a dedicated **trusted self-hosted Windows** runner carrying label
`pt-game-build`. No fork PRs are permitted to run on the game build host.
Provide sufficient temporary storage for the copied source, object files and
compiler output, and a reproducible VS2022/Windows SDK/DirectX 9 setup.

The repo-hosted source/PowerShell smoke workflow is separate: its green result
does not imply that this complete build was executed.

## Binary acceptance matrix

The builder and `tools/verify_windows_build.py` expect **22 role-specific outputs**:

| Role | Expected output |
| --- | --- |
| Client | `Game.exe`, `Engine.dll`, `LuaLibDll.dll`, `CoreClient.dll`, `ExpandPackage.dll`, `FilterText.dll`, `Heaven.dll`, `Rainbow.dll`, `Represent2.dll`, `Represent3.dll` |
| Server | `Engine.dll`, `LuaLibDll.dll`, `CoreServer.dll`, `ExpandPackage.dll`, `FilterText.dll`, `Heaven.dll`, `Rainbow.dll`, `PhongThanAccountServer.exe`, `PhongThanRelay.exe`, `Bishop.exe`, `Goddess.exe`, `GameServer.exe` |

The new native relay is `PhongThanRelay.exe`; **do not confuse it**
with the old staging `PhongThanRelayServer.exe` name.

The verifier fails closed on missing/truncated files, missing DOS/PE headers,
wrong machine type (requires i386), PE32+ instead of PE32, or EXE/DLL type
mismatch. It writes a **metadata-only JSON** inventory (relative paths, byte
counts, SHA-256). It never publishes executable contents, PAK files or saves.

```powershell
python tools/verify_windows_build.py `
  --output-root 'D:\PT-Build\PhongThanSource\OutputModern' `
  --report 'D:\PT-Build\build-evidence.json'
if ($LASTEXITCODE -ne 0) { throw 'Required PE32 x86 binaries missing or invalid.' }
```

### Preventing stale binary false positives

The archive can contain historical `OutputModern/` EXE/DLL and
`Build/LogsModern/` files. `tools/Build-PatchedGame.ps1` now runs
`tools/prepare_modern_build.py` **after copying sources outside the checkout**:
it rejects source/repository overlap, unexpected files and symlink/junction
output directories, then removes only the copied output and log directories.
The builder also receives `-Clean` to recompile project intermediates.

A `PASS` from `verify_windows_build.py` therefore requires 22 files emitted
again in that cleaned external workspace; it does **not** prove runtime
imports, gameplay or reproducibility across separate toolchain installs.
Tests use synthetic tiny directories and never execute the game.

Run the verification only against a **fresh completed build**, not archived
`OutputModern/` or a partly rebuilt directory. A structurally valid PE is
not proof its Windows DLL imports resolve or the game can actually start.

## GitHub-hosted native module baseline (14/10/2026 — 2/2 PASS)

`.github/workflows/windows-native-modules.yml` builds **LuaLibDll** and **Engine**
from a fresh, source-only external copy on `windows-2022` (MSVC x86).
It uses a sparse checkout of relevant source/headers plus the original
`Lib/release/` libraries required for Engine linking; it excludes
`Output/`, `OutputModern/`, PAK, SQL, runtime saves and staged binaries.
The job compiles/links both projects and checks the freshly generated
Client/Server DLL files as PE32/i386, with SHA-256 in a metadata-only artifact.
Each target is reported independently even when another target fails.

- Automatic: relevant PRs and changes on `main`; manual: `workflow_dispatch`.
- [GitHub-hosted Windows run #38520540848](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38520540848): **LuaLibDll PASS; Engine PASS** (freshly emitted DLL PE32/i386 plus SHA-256).
- **Caveat:** Engine currently links some archived `Lib/release/` dependencies, including `JpgLib.lib`; this is not a clean rebuild of every transitive static library.
- Green module CI is not the 22-binary full build and does not execute the game.
- Next stage after module successes: dependency-aware `CoreServer` and
  `GameServer`/client build in an isolated workspace, then M2 runtime UAT.

## GitHub-hosted Core module gate (14/10/2026 - 7/7 PASS)

`.github/workflows/windows-core-modules.yml` extends the hosted MSVC x86
build baseline to **Common**, **ExpandPackageStaticLib**, **FilterTextStatic**,
**CoreServer.dll**, and **CoreClient.dll** alongside LuaLibDll and Engine.
It uses a fresh, source-only external workspace, sparse-checkout headers and
existing legacy `Lib/release` linker inputs. Game runtime, SQL, PAK and saves
are not checked out or executed.

[Windows Core run #38523254976](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38523254976)
reported **7/7 PASS**, with freshly emitted role-specific PE32/i386 DLLs
and COFF static libraries checked for signatures and SHA-256. This is not
a clean rebuild of all transitive archived libraries, not a completed
22-binary release build and not runtime/gameplay acceptance.

**Next:** dependent native server binaries (Bishop, Goddess, GameServer)
and GameClient/Game.exe, then full 22-output verification in a clean
release build; isolated Windows world-ready/login/save UAT follows.

## GitHub-hosted native Server build gate (14/10/2026 - 15/15 PASS)

`.github/workflows/windows-server-modules.yml` uses a fresh external Windows
source build on `windows-2022`. The source-only sparse checkout excludes
`PhongThanRuntime-Staging`, SQL, PAK, player saves, and historical build outputs.
The existing AccountServer compatibility overlay is applied **only to the
external copy**, never to the tracked archive.

[Windows server build run #38526607624](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38526607624)
verified **15/15 newly built targets** by compile/link and PE32/i386 or COFF
signature plus SHA-256. This includes five real server executable outputs:
`Goddess.exe`, `PhongThanAccountServer.exe`, `PhongThanRelay.exe`,
`Bishop.exe`, and `GameServer.exe`.

The other ten targets are LuaLibDll, Engine, Common, ExpandPackageStaticLib,
FilterTextStatic, CoreServer, ExpandPackage, FilterText, Heaven, and Rainbow.
Some linker inputs are still archived legacy `Lib/release` libraries;
the job does not prove a fully self-contained clean rebuild of all
transitive dependencies.

**Not tested:** starting any server process, DB readiness, 102-map world
registration, login, character persistence, gameplay, or public network.
Next: complete the missing Client modules and `Game.exe`, verify the
entire fresh 22-role EXE/DLL matrix in a release workspace, and then
perform M2 testing using an isolated test-only Windows runner/VM.

## GitHub-hosted native Client build (14/10/2026 - 13/13 PASS)

[Windows Client run #38530141589](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38530141589)
compiled and linked **13/13 source projects** in an isolated external Windows
x86 workspace, including freshly built `Game.exe`, `Represent2.dll`,
`Represent3.dll`, `CoreClient.dll`, and both Client/Server role copies of
shared DLLs. Metadata-only PE32/i386, COFF and SHA-256 checks passed.
[PR #57](https://github.com/ePlus-Game/phong-than-truyen-ky/pull/57)
provides the reproducible workflow and tests.

The build uses legacy `Lib/release` linker inputs where needed. The
Represent3 workaround only changes the **temporary copied DSP/builder**
to avoid old DX9 headers shadowing the modern Windows SDK and to order
`windows.h` before DirectDraw. Tracked historical source bytes remain
unchanged.

**Next P4:** compile Client and Server **together** in one fresh source
workspace, verify **22/22 role-specific EXE/DLL** via
`tools/verify_windows_build.py`, and inspect native import dependencies.
A successful Client build alone is not evidence of playable gameplay or DB.

## Combined hosted build and static dependency gate (14/10/2026)

The [combined Windows x86 build run #38531158753](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38531158753)
compiled **19/19 projects** and verified **22/22 freshly emitted Client/Server
EXE and DLL roles** from a single copied source workspace. PE32/i386 and
SHA-256 validation passed. This supersedes the earlier unverified full-build
status; archive and staging content remain unchanged.

The `.github/workflows/windows-combined-build.yml` stage
(`tools/audit_windows_imports.py`) statically inspects **normal imports
and delay-load DLL descriptors** of each newly built PE32 file. A missing
project DLL in the required Client/Server role or malformed import table
fails CI. External DLL names are recorded separately as runtime
requirements **not yet verified** on a clean Windows test VM. The JSON
artifact contains filenames and import metadata only, no EXE/DLL bytes,
passwords, game state or player saves.

[PASS import audit run #38546154123](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38546154123) parsed normal and delay-load imports for **22/22 binaries**, with no missing project-local DLL role or malformed import table. Four names remain to verify in the disposable Windows runtime environment: `dinput8.dll` and `odbc32.dll` (Windows components), and `msvcp140.dll` plus `vcruntime140.dll` (Visual C++ runtime components). The audit did **not** verify availability or version on a target VM.

This audit is **not** proof of OS loader success: dependent DLL files can
still be absent from the intended deployment, have wrong exports, or fail
initialization. The next gate is to assemble a disposable test package,
validate imports against a Windows x86 VM and safely launch five services
with a test-only database (M2). Do not start native code on untrusted
self-hosted runners or production data.

## Manual execution and evidence

1. Provision the dedicated trusted Windows x64 runner with MSVC x86 tools,
   Windows SDK, legacy DX9 libraries and temporary disk. Ensure it holds **no
   production database, client login tokens or real player saves**.
2. In GitHub Actions, select *Windows x86 full game build (isolated, manual)*,
   `main`, enable the isolated-build confirmation, and run.
3. Review each project log plus `pt-build-manifest.json` in the
   `windows-x86-build-evidence` artifact. Do not upload binary/PAK artifacts
   or unredacted environment files.
4. If build fails, preserve concise compiler/linker diagnostics (not secrets),
   fix the module **via external-source overlay**, add regression coverage,
   and rerun with a new workspace.
5. When this passes, move to M2's isolated Windows native service startup,
   world-ready 102 maps, test login, save/load and graceful shutdown.

## Verified GitHub-hosted Windows module builds (14/10/2026)

These are **native MSVC x86 compile/link tests on external copied source**, not runtime acceptance:

| Module | Evidence | Result |
| --- | --- | --- |
| `PhongThanRelay.exe` | [Windows run #38496333559](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38496333559) | Compile/link + PE32/i386 + SHA-256 **PASS** |
| `PhongThanAccountServer.exe` | [Windows run #38497824476](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38497824476) | Original-byte overlay (including explicit Winsock2) + compile/link + PE32/i386 + SHA-256 **PASS** |
| `LuaLibDll.dll` (Client/Server roles) | [Windows run #38520540848](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38520540848) | Fresh compiled DLL, PE32/i386 and SHA-256 **PASS** |
| `Engine.dll` (Client/Server roles) | [Windows run #38520540848](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38520540848) | Fresh compiled DLL linked with legacy static/import dependencies, PE32/i386 and SHA-256 **PASS** |

The AccountServer smoke patch source is staged using `python -m
tools.stage_accountserver_smoke --target <external-workspace>`.
A failed run exposed missing `SOCKET`/Winsock declarations in the legacy
`GlobalFun.h`. The verified patch fixes this **in the copied source**;
the archived source and runtime data remain unmodified.

**Next:** verify imported dependencies and disposable Windows package for the complete 22/22 build, then test native service startup and gameplay in isolation. A successful compile does not establish runtime readiness.

## Existing guarantees and missing tests

- **Present**: Python/C++98 static-source checks, PowerShell syntax checks,
  readiness marker parser tests, and 22-binary PE32/x86/hash contract tests.
- **Not yet demonstrated**: Windows loader/import resolution on a clean VM; process startup; login/reconnect;
  player save persistence; gameplay; or Internet/multi-server stability.
- **Do not release publicly** until M2/M3 transaction and persistence acceptance
  conditions in [MASTER_ROADMAP.md](MASTER_ROADMAP.md) pass.

See [TEST_MATRIX.md](TEST_MATRIX.md) for the evidence tiers.
