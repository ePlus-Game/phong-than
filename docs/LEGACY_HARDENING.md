# Legacy security and build hardening

The original ZIP mirror under source/PT/ is **intentionally byte-exact**.
Do not modify it to fix game code: its SHA-256 inventory is part of the
recovery evidence. Use a separate working copy of PhongThanSource.

## Apply the tested C++ hardening overlay

1. Copy the source/PT/PhongThanSource directory to a local build workspace
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
- Reject absent or malformed gateway client-info strings instead of reading
  past a missing colon delimiter.
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

CI currently validates portable Lua/Common libraries and static/VC6 build
preflight. It does NOT build or run the complete Windows GameClient,
GameServer, AccountServer or gameplay. Follow the original-source build
matrix in source/PT/PhongThanSource/README.md for the copied workspace.
Build and smoke tests must run in an isolated Windows x86 VM.
