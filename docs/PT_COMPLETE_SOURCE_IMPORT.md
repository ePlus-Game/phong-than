# PT complete source mirror — no file filtering

Source: original `PT.zip` in Google Drive.

All files are imported from these original paths, **without filtering by filename, extension, build directory, or binary/text content**:

- `PT/PhongThanSource/**` (including `Build`, `Deploy`, `Output`, `ThirdParty`, `Lib`, historical `.git` and all other files).
- `PT/AdminWeb/**`, `PT/docs/**`, `PT/_backup/**`.
- Every file directly under `PT/`.
- Client and Server runtime source trees: `PT/PhongThanRuntime-Staging/{Client,Server}/{script,settings,Ui}/**`.

Inventory (from ZIP manifest, before Colab execution): **24,827 original source-tree files**, **2.583 GiB uncompressed**, including **2,766 historical `.git` files**.
Original `.git` cannot be staged as nested Git files; all of its original contents are preserved in `source/PT/PhongThanSource/__historical_git__/original-dot-git.zip` with original paths. All other files mirror original paths into `source/PT/...` unchanged.
The notebook writes `source/PT_SOURCE_MANIFEST.csv` with one row per original source file and a SHA256 (or an archive CRC for historical `.git` members).

This is a full source-tree import, NOT a GitHub Release. Packaged runtime assets outside code trees (`Client/data/*.pak`), SQL installation packages in `PT/Setup`, and runtime database state in `PT/PhongThanRuntime-State` are not source code and are outside scope.

Colab: `PT_All_Source_No_Filter_Colab.ipynb` in My Drive. It uploads all source files to branch `import/pt-unfiltered-source-mirror` in chunks. If any member cannot be preserved or pushed it **stops rather than skips**. `MyDrive/PT_Git_Staging/PT_All_Source_Complete_Report.json` confirms completeness.

**PUBLIC REPOSITORY WARNING:** This source contains older backups, configs, binaries and historical Git objects that might contain secrets, account data, or unlicensed third-party content. Public disclosure requires appropriate rights and review. CI success is not a guarantee of safe publication or that the original game runs.
