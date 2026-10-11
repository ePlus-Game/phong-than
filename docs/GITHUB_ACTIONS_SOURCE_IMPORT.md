> **Historical workflow documentation:** These instructions refer to an obsolete import workflow removed after the full PT.zip import. Do not use these steps for the current repository. See [current layout](REPOSITORY_LAYOUT.md) and the workflows in `.github/workflows/`.

# GitHub Actions for Phong Than recovery (Colab → GitHub)

This project uses **one main repository**, `ePlus-Game/pt`, for source code and CI.
The original `PT.zip` (9.1 GB) stays in Google Drive. Runtime, account databases,
compiled executables, game `.pak`/`.dat` assets and the old `.git` directory are **not**
meant to be pushed to the source repository.

## Why hybrid import instead of downloading all of PT.zip in Actions?

GitHub-hosted runners do not automatically have access to the user's private Drive.
Downloading the 9.1-GB archive and extracting around 12.9 GB of files is not a
reliable fit for hosted-runner disk limits. **Do not make the Drive ZIP public
just to feed CI.**

Use `PT_Colab_Chunk_Push_GitHub.ipynb` in Google Colab once to:

1. Authorize Drive and GitHub, using a narrowly scoped fine-grained PAT entered
   in the notebook's hidden prompt (do not paste secrets into notebook cells).
2. Read only candidate source from `PT/PhongThanSource/` in the ZIP.
3. Commit small batches to `import/pt-recovered-source` under
   `recovered/PhongThanSource/`, never directly to `main`.
4. Resume from the last pushed commit if Colab disconnects.

## What GitHub Actions automates after that

Every push to `import/**` triggers
[`recovered-source-import.yml`](../.github/workflows/recovered-source-import.yml):

- Check the branch diff against `main`, **without executing old game files**.
- Refuse changes outside `recovered/PhongThanSource/`, compiled/binary files,
  excessive file sizes, suspicious names and basic credential patterns.
- Publish an Actions run summary and downloadable `recovered-source-report`.
- Attempt one **Draft PR** for the branch when the check succeeds; reuse an
  existing open PR rather than creating duplicates. If Actions PR creation is
  restricted by repository or organization policy, use its compare link.

To permit automatic Draft PRs, review GitHub
**Settings → Actions → General → Workflow permissions →
Allow GitHub Actions to create and approve pull requests**.
This is optional: the source safety check runs even if PR creation is disabled.

You can manually rerun the workflow at
**Actions → Review recovered Phong Than source → Run workflow**, selecting the import branch.

## Constraints

- **`ePlus-Game/pt` is currently public**: pushed files are immediately visible
  to others, even when the PR is Draft. First check copyright and permission to
  redistribute original Kingsoft/game source.
- The gate is a first-pass heuristic, **not** a comprehensive security or license
  audit. Review changed source files, copyright notices, configurations, and
  credentials manually before merge.
- The current original-source CI builds only portable subsets. Neither this
  workflow nor the import notebook proves that the complete game works.
- Keep account backups, `.mdf`/`.ldf`, `.bak`, DLL/EXE, `.pak`/`.dat`,
  protected archives, and old `.git` data in separately permissioned storage.
