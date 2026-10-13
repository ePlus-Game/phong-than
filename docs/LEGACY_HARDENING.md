# Legacy security and build hardening

The original `PhongThanSource/` and other original PT.zip folders are **intentionally byte-exact**.
Do not modify it to fix game code: its SHA-256 inventory is part of the
recovery evidence. Use a separate working copy of PhongThanSource.

## Apply the tested C++ hardening overlay

1. Copy the PhongThanSource directory to a local build workspace
   OUTSIDE this Git checkout (Windows VM with suitable storage recommended).
2. From the repository root, run:
   python tools/legacy_hardening.py --target /external/copy/PhongThanSource
3. If the dry run succeeds, run:
   python tools/legacy_hardening.py --target /external/copy/PhongThanSource --apply
4. Build the copied tree with its Build/Build-PhongThan.ps1 and licensed VC6
   toolchain. A passing Python test does not establish binary/ABI compatibility.

These fixes are made ONLY to the copied workspace:
- Reject missing/oversized account packet data BEFORE memcpy in CustomSend.
  Release builds do not execute assert statements.
- Validate the legacy `IPv4:port` gateway string with a portable C++98 helper;
  reject malformed hosts and ports instead of using an unbounded colon scan.
- Install the helpers only into the external working copy; the original game
  source files remain byte-for-byte unchanged.
- Reject inbound gateway frames outside the existing wire-header minimum and
  1 MiB maximum before narrowing `size_t` to DWORD. Use a portable C++98
  length check for outbound `CustomSend` as well; do not change the protocol.
- Treat Lua error text as data, not a fprintf format string.

The overlay matches exact source contexts and preserves existing CRLF line
endings. If the original source changes unexpectedly, patching refuses to
proceed rather than guessing.

## Security warning for the public repository

The full PT.zip is currently published inside a PUBLIC GitHub repo.
It contains database backups, character save data, runtime configs/logs
and bundled historical Git metadata. Run:

    python tools/audit_sensitive_paths.py --json risk.json --markdown risk.md

This scans tracked FILENAMES only and deliberately does not print account
data or secrets. CI reports aggregate counts; it cannot certify privacy.
If any data is real, urgently restrict repository access and assess
credential rotation, backups, redistribution rights and **history cleanup**.
Adding .gitignore or deleting in a new commit does not make prior commits
private. Preserve an authorized offline byte-exact recovery copy separately
before any history operation.

## Existing build limitations

CI validates Python recovery tooling and source preflight only. It does NOT compile or run a complete Windows GameClient,
GameServer, AccountServer or gameplay. Follow the original-source build
matrix in PhongThanSource/README.md for the copied workspace.
Build and smoke tests must run in an isolated Windows x86 VM.


## One-command patched Windows build (the copied source only)

Install Python 3.10+ and a compatible Windows x86 build environment:
- Modern: Visual Studio 2022 Build Tools with MSVC v143 x86, WinSDK;
- Legacy: licensed Visual C++ 6.0 with the original project dependencies;
- the GDI+ / DirectX 9 SDK headers and import libraries under ThirdParty.

Use an isolated Windows VM with at least 20 GiB of free space.
Run these commands from the repository root:

    .\tools\Build-PatchedGame.ps1 -WorkRoot 'D:\PT-Build\PhongThanSource' -Toolchain Modern -PreflightOnly
    .\tools\Build-PatchedGame.ps1 -WorkRoot 'D:\PT-Build\PhongThanSource' -Toolchain Modern

For VC6 Debug:

    .\tools\Build-PatchedGame.ps1 -WorkRoot 'D:\PT-Build\PhongThanSource' -Toolchain VC6 -Configuration Debug

Choose a NEW WorkRoot for each build. The wrapper refuses to overwrite
existing output or modify the tracked original ZIP mirror. It copies source,
applies VC6-compatible patches and executes the chosen compiler. Modern supports
Release only. Inspect the generated Build/Logs or Build/LogsModern outputs
if the build fails. Compiler success is not a Client/Server smoke-test pass.

## Versioned recovery-toolkit prerelease

Merging the version notes file under docs/releases/v0.1.0-recovery.1.md
triggers a recovery-TOOLKIT release after Python unit tests and a static build
preflight pass. The attached ZIP contains only developer tools
and documentation plus SHA-256 checksum, NOT game DLLs, EXEs, PAKs or account
data. The full original repository remains public and GitHub may automatically
provide source archives alongside the toolkit. The version tag must not be
interpreted as proof that the game can run.

## Refactor tests (without original game binaries)

From the repository root run:

```bash
python -m unittest discover -s tests -v
g++ -std=c++98 -Wall -Wextra -Werror -pedantic tests/cpp/test_gateway_endpoint.cpp -o /tmp/pt-gateway-test
/tmp/pt-gateway-test
g++ -std=c++98 -Wall -Wextra -Werror -pedantic tests/cpp/test_account_packet_bounds.cpp -o /tmp/pt-account-bounds-test
/tmp/pt-account-bounds-test
```

These test the parser and the source patch process. They do not prove
compatibility with the original VC6 compiler or a playable game.
