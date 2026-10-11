# Phong Thần 2 — exact PT.zip archive and recovery tools

This repository preserves the **original PT.zip archive**, byte-verified, under
`source/PT/`. The original contains **99,352 entries**. It is **not a
proven playable Client/Server build**.

## Repository layout

- `source/PT/` — sole canonical archive source tree, including the original
  PhongThanSource project, packaged runtime data and all split PAK parts.
- `source/PT_EXACT_ZIP_MANIFEST.csv` — original file sizes and SHA-256 inventory.
- `source/PT_EXACT_ZIP_DIRECTORIES.txt` — original empty directories.
- `source/PT_RESTORE_SPLIT_FILES.py` — restore the 16 large PAK files from
  102 Git parts, with size and SHA-256 verification.
- `tools/`, `tests/`, `docs/`, `.github/` — recovery tooling, tests,
  documentation and CI for the original source mirror.

The earlier standalone source subset at the repository root (`Base/`,
`Client/`, `Server/`, `Share/`) and the obsolete `recovered/` import
were removed to avoid confusing them with the canonical PT.zip source.
**These removed files may still exist in earlier Git commits.**

## Restore the 16 large PAK files

After cloning the repository, from the repository root run:

```powershell
python source/PT_RESTORE_SPLIT_FILES.py --repo-root .
```

The archive source tree is intentionally unmodified. To experiment with fixes,
copy `source/PT/PhongThanSource/` **outside** the checkout and follow
`docs/LEGACY_HARDENING.md`. No complete game build, login, or gameplay
test is established.

## Security and licensing

**This repository is PUBLIC.** The original archive may contain account
backups, character records, logs, server settings, historical Git objects and
third-party proprietary material. Public access does not grant redistribution
rights. Review any personal data and credentials before sharing. Deleting
old files in a new commit does not erase their Git history.
