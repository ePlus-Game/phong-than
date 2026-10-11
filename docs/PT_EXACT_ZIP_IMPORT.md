> **Historical import notes:** This page describes the initial import paths. Since the repository layout change, the contents of `source/PT/` are at the repository root, original PT docs are under `docs/original-pt/`, the unchanged manifests are under `archive/`, and the restore command is `python tools/restore_split_files.py --repo-root .`. See [current layout](REPOSITORY_LAYOUT.md).

# Full PT.zip import — ordinary Git chunks, no LFS

## Goal
Reconstruct the original **99,352 files** from `PT.zip`, byte-identical. This project does not use GitHub Releases or Git LFS.

## Import map
- Files smaller than **90 MiB** are committed at their original relative path under `source/PT/`; the expected Git blob SHA-1 is computed from the exact original bytes, preventing CRLF/LF or encoding changes.
- **16 large PAK files** (approximately **7.26 GiB**) become **102 Git blobs** of at most **80 MiB** each, stored at `source/PT/<original-name>.pak.parts/part-0000.bin`, etc. This is required because GitHub rejects an individual Git blob of at least 100 MiB.
- After clone, run `python source/PT_RESTORE_SPLIT_FILES.py --repo-root .` to reconstruct each large PAK at its original location. The script validates the original SHA-256 and byte count, and fails if a chunk is missing or corrupted.
- **2,766 historical `.git` member files** cannot be staged as nested Git repository internals; their unchanged bytes are preserved in `source/PT/PhongThanSource/__historical_git__/original-dot-git.zip`, individually SHA-256 verified. Extract them when restoring the historical nested `.git`.
- Original empty directories are stored in `source/PT_EXACT_ZIP_DIRECTORIES.txt`.

## Verification
- `source/PT_EXACT_ZIP_MANIFEST.csv` records every original ZIP member's path, original byte length and SHA-256, plus whether the bytes are stored as a normal Git blob, split parts, or historical ZIP archive.
- Every Git blob/index SHA-1 is compared to the exact ZIP bytes or chunk bytes. Original full-file SHA-256 is verified as split chunks are written.
- All 99,352 files must be mapped, with **zero missing items** and **zero mismatches**; a failed push or hash mismatch stops, never silently excludes the item.
- The original `PT.zip` remains unchanged on Drive. The report is `MyDrive/PT_Git_Staging/PT_Exact_Zip_Complete_Report.json`. Only a report with `complete: true`, `missing_paths: 0`, `byte_mismatch: 0` and matching remote commit permits calling the import complete.

## Run
Use the Colab notebook `PT_Exact_Unzipped_Chunk_Push_v2.ipynb`. Its target branch is `import/pt-exact-unzipped-tree` (Draft PR #13). It can resume by checking committed Git blob hashes. For safety, keep the PR as draft until real ZIP validation finishes.

## Important
`ePlus-Game/pt` is **PUBLIC**. The ZIP may contain account databases, personal data, legacy secrets and third-party materials. Do not approve public disclosure without checking rights and sensitive information; moving the repo private before upload is safer. GitHub may also reject the overall ~12 GiB repository on performance/size grounds despite each individual blob being <100 MB.
