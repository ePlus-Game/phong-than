# Phong Thần 2 — source preservation and recovery

This repository contains an **archived, byte-verified copy of PT.zip** and a
separate, incomplete legacy build/recovery project. It is **not yet a proven
playable Client/Server build**.

## Repository map

- source/PT/ — mirror of the original archive's 99,352 file entries, with
  SHA-256 manifest at source/PT_EXACT_ZIP_MANIFEST.csv.
- source/PT/PhongThanSource/Sources/ — original C/C++ Client, Engine, Account
  and game-server projects, with VC6 and experimental modern build scripts.
- source/PT/PhongThanRuntime-Staging/ — original packaged Client/Server data.
- source/PT/AdminWeb/ — local PowerShell administration UI.
- Base/, Client/, Server/, Share/ — earlier standalone portable source subset.
- tools/ and tests/ — read-only audit, migration and CI helpers.

Sixteen original large PAKs are stored as 102 chunks under *.pak.parts.
After cloning, restore those exact bytes with:

    python source/PT_RESTORE_SPLIT_FILES.py --repo-root .

Old embedded .git objects are preserved in a recovery ZIP, and empty
directory entries are documented separately. See docs/PT_EXACT_ZIP_IMPORT.md.

## Next development steps

1. **Security review first.** This repository is PUBLIC and contains account
   database backup files, character records, logs and configs. Its existence
   does not mean the material is appropriate to redistribute. See
   docs/LEGACY_HARDENING.md for the privacy/history warning.
2. Keep source/PT/ as the original unmodified baseline. Apply reviewed fixes
   to a COPY with tools/legacy_hardening.py as described in
   docs/LEGACY_HARDENING.md.
3. Use the original VC6 build scripts inside an isolated Windows x86 VM.
   CI only builds portable Lua/Common components, not the complete game.
4. Record real compiler results, login and map-entry smoke tests before
   claiming the game is operational.

The original proprietary Kingsoft/VNG-era code and assets carry their own
rights and notices. Repository access does not grant permission to
redistribute or relicense this material. Do not run unknown binaries
directly on a personal/production computer.
