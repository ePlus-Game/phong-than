# PT.zip import metadata (unchanged)

These inventories were generated during the original full PT.zip import.
Their historical file paths use `source/PT/`, even though the archived
files are now at the repository root. The archive data itself is preserved
byte-for-byte.

- `PT_EXACT_ZIP_MANIFEST.csv`: original file sizes, SHA-256 hashes and
  split PAK storage paths.
- `PT_EXACT_ZIP_DIRECTORIES.txt`: original empty directory entries.
- `PT_SOURCE_MANIFEST.csv`: early source-mirror verification inventory.

**Do not modify these inventories to reflect the new folder layout.**
See `docs/REPOSITORY_LAYOUT.md` for path mapping and
`python tools/restore_split_files.py --repo-root .` to restore split PAKs.
