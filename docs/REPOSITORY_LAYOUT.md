# Repository layout — PT.zip at the repository root

The contents of the original `PT/` directory of `PT.zip` are directly
under the **repository root**. This eliminates the former `source/PT/`
wrapper; it does not rebuild, re-encode or filter the archived game files.

| Path | Purpose |
| --- | --- |
| `PhongThanSource/` | Original C/C++ client/server sources and build scripts |
| `PhongThanRuntime-Staging/` | Original staged client/server runtime files and assets |
| `PhongThanRuntime-State/` | Original runtime state archived in PT.zip |
| `AdminWeb/` | Original administration utilities |
| `Setup/`, `_backup/` | Original installation and backup materials |
| `PhongThan-*.cmd`, `CHANGELOG.md` | Original ZIP-root scripts and changelog |
| `docs/original-pt/` | **Original PT/docs/**, kept separate from repository docs |
| `archive/PT_EXACT_ZIP_MANIFEST.csv` | Unmodified import-time SHA-256 inventory |
| `archive/PT_EXACT_ZIP_DIRECTORIES.txt` | Unmodified original empty-folder inventory |
| `archive/PT_SOURCE_MANIFEST.csv` | Unmodified historical source subset inventory |
| `tools/restore_split_files.py` | Restore the 16 split PAKs using the original manifest |
| `tools/`, `tests/`, `.github/`, `docs/` | Repository-maintained utilities |

## Historical manifest path mapping

The CSV manifests intentionally keep their **historical path names**
(`source/PT/...`), because they are import evidence. Do not edit/recalculate
them just to reflect a move.

For the current layout, strip the `source/PT/` prefix. The sole collision
with repository-maintained paths is the original archive's `PT/docs/`;
those files are preserved unchanged under `docs/original-pt/`.

Example: `source/PT/PhongThanRuntime-Staging/Client/data/a.pak` is now
`PhongThanRuntime-Staging/Client/data/a.pak`. The old CSV entries may point
to `source/PT/...`, but file bytes and SHA-256 checksums remain unchanged.

## Verify or restore the data

```powershell
python -m unittest discover -s tests -v
python tools/restore_split_files.py --repo-root .
```

The second command can require more than 7 GiB of free space and recreates
PAKs at their current root-relative paths with SHA-256 verification.

The original `.git` members inside the original ZIP were already archived
in `PhongThanSource/__historical_git__/original-dot-git.zip`. They are not
the active Git repository metadata.

## Security and builds

This is a **public** historical archive, not a verified playable game.
Its original content may include account records, backups, credentials,
third-party materials and old executables. Do not run original binaries on a
trusted/production machine, and do not treat a green CI as a complete game
build. Removing/relocating data in current Git commits does not scrub history.
