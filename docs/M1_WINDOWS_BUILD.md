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

The AccountServer smoke patch source is staged using `python -m
tools.stage_accountserver_smoke --target <external-workspace>`.
A failed run exposed missing `SOCKET`/Winsock declarations in the legacy
`GlobalFun.h`. The verified patch fixes this **in the copied source**;
the archived source and runtime data remain unmodified.

**Next:** build `Engine`, `LuaLibDll`, `CoreServer`, `GameServer` and
`Game.exe` with all dependencies, then verify the complete 22-binary
matrix. A module build may succeed while the real full build or live
service startup fails.

## Existing guarantees and missing tests

- **Present**: Python/C++98 static-source checks, PowerShell syntax checks,
  readiness marker parser tests, and 22-binary PE32/x86/hash contract tests.
- **Not yet demonstrated**: successful full Windows x86 build in GitHub
  Actions; DLL import resolution; process startup; login/reconnect;
  player save persistence; gameplay; or Internet/multi-server stability.
- **Do not release publicly** until M2/M3 transaction and persistence acceptance
  conditions in [MASTER_ROADMAP.md](MASTER_ROADMAP.md) pass.

See [TEST_MATRIX.md](TEST_MATRIX.md) for the evidence tiers.
