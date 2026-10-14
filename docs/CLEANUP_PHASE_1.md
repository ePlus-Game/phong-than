# Repository cleanup — phase 1

This change prevents new build/runtime debris. **It does not delete the original PT.zip-derived files** or claim to reduce Git history size.

## What changed

- Extended `.gitignore` for local C++ build caches, crash dumps, temporary files, reports, and runtime artifacts.
- Added a lightweight PR guard that checks *newly added* paths using the GitHub API, without checking out the multi-gigabyte repository.
- Existing tracked archives, save state, 16 split PAKs (102 parts), and the runtime required by game startup remain unchanged.

## Phase 2: archive and remove tracked debris safely

1. Create independent, access-controlled archive of the imported tree. Verify manifest and SHA-256 checksums, including all PAK parts.
2. Inventory tracked paths: `git ls-files -z` and `git ls-tree -r -l HEAD`. Review logical size **and unique blob hashes**. Never inspect or post secret-bearing logs/SQL publicly.
3. Compare launcher, build scripts and test dependencies before marking any runtime files removable.
4. In a separate cleanup branch, remove verified redundant tracked paths with `git rm --cached -- <path>` (to untrack while keeping local files). Document exact paths and any restore location.
5. Test clean clone, PAK restoration, Windows x86 native build, and game startup, then merge.
6. A HEAD cleanup alone will **not** shrink existing Git history. Evaluate history rewrite / separate source repository only with backups, migration instructions, and coordination with all users.

Do not broadly run `git rm -r PhongThanRuntime-Staging`, `git rm -r PhongThanSource`, or force-push rewritten history.
