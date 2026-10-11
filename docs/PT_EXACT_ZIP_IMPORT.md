# Exact-byte import of the complete original PT.zip

## Goal
Mirror **every file** from the original `PT.zip` into `source/PT/` on `ePlus-Game/pt`, not just source-code extensions. Verify byte-for-byte contents before accepting completion. No GitHub Releases and no intentional exclusion of files or folders.

## Original inventory
- `PT.zip`: 99,352 file entries, about 11.98 GiB uncompressed (based on the ZIP manifest); directory entries are recorded separately.
- 16 `.pak` files each >=100 MiB; GitHub rejects ordinary Git blobs >=100 MiB. Use Git LFS for these specific 16 paths. The original bytes can be recovered with `git lfs pull`; plain Git history retains LFS pointer objects.
- 2,766 entries in nested `PT/PhongThanSource/.git/`; the byte contents of each entry are packaged in `source/PT/PhongThanSource/__historical_git__/original-dot-git.zip` because Git cannot track an embedded `.git` directory normally. The notebook verifies the SHA-256 of each original `.git` member inside that archive.

## Verification
- `source/PT_EXACT_ZIP_MANIFEST.csv`: one record per original ZIP file with original name, Git path or archive path, original size, SHA-256 and storage type.
- `source/PT_EXACT_ZIP_DIRECTORIES.txt`: every original ZIP directory entry, including empty directories which Git cannot directly track.
- For non-LFS files, compare the exact original Git blob SHA-1 (`blob <size>\0<data>`) with the index entry, bypassing any line-ending conversions.
- For Git LFS, verify the Git pointer contains the original file's SHA-256 and size, and that LFS upload succeeds before reporting completion.
- All 99,352 files must have a matching Git/LFS or archived `.git` representation; an unhandled failure aborts, never silently skips.
- Report in `MyDrive/PT_Git_Staging/PT_Exact_Zip_Complete_Report.json`, with `complete: true` only after all comparisons and the remote branch SHA succeed.

## Execute
Run `PT_Exact_Unzipped_Colab.ipynb` from Google Drive with `Runtime → Run all`. It creates/resumes branch `import/pt-exact-unzipped-tree`. If interrupted, rerun to reverify and skip hashes already committed on the branch.

## Important restrictions and security
Repo `ePlus-Game/pt` is PUBLIC, and the full ZIP contains account database backups, logs, original code and third-party resources. Do not authorize public push unless distribution rights and any personal data have been reviewed. The notebook stops at an explicit confirmation when the repository is public. LFS bandwidth/storage quotas may also prevent a full upload.

An ordinary Git clone without LFS retrieval gives pointer files for 16 assets. Run `git lfs pull` to restore those bytes. A Git checkout will not restore historical nested `.git` entries or empty directories automatically; unpack the historical archive and recreate empty directories using the inventory.
