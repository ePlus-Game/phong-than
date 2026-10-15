# GitHub Actions audit — 15 October 2026

## Before / after

- **Before:** 26 separate GitHub Actions workflow YAML files.
- **After:** 14 files. **14 obsolete YAMLs removed and 2 consolidated workflows added.**
- The removed workflows are not game assets, and the release, repository
  history, data and earlier Actions logs remain intact.
- No live SQL, game processes, PAK files, character saves or runtime DLLs
  are touched by this change.

## Consolidated (tests preserved)

| New workflow | Replaces | What still runs |
| --- | --- | --- |
| `admin-web-checks.yml` | `admin-locale-checks.yml`, `admin-workspace-checks.yml`, `windows-pak-install.yml` | One Windows 2022 job: Node 24 tests for 24 Admin panels, UTF-8/TVCN3 text, PowerShell 5.1 parsing, API locale, synthetic 15-table PAK gate, installer safety checks |
| `windows-client-ui-regressions.yml` | `windows-client-cursor.yml`, `windows-font-bytes.yml`, `windows-font-fallback.yml`, `windows-font-ui-status.yml` | One Windows 2022 x86 job: native cursor test, font-id fallback test, CRLF/newline test, ASF glyph audit, character status UI byte test |

The font audit JSON remains available as a **7-day artifact**; no font,
runtime binary or player data is uploaded.

## No longer necessary

| Removed workflow | Why it is redundant or obsolete |
| --- | --- |
| `windows-client-modules.yml` | All Client/native renderer binaries are already built and checked in `windows-combined-build.yml` |
| `windows-server-modules.yml` | The combined 22-binary build covers Server and AccountServer |
| `windows-core-modules.yml` | Core and Engine compile/link coverage is included in the combined build |
| `windows-native-modules.yml` | Engine/LuaLibDLL coverage is included in the combined build |
| `windows-x86-build.yml` | Old manual full build duplicates the combined workflow, uses older action versions, and does not add unique test coverage |
| `repository-cleanup-inventory.yml` | Duplicate of remaining manual `repository-hygiene.yml` inventory |
| `recovery-toolkit-release.yml` | Historical single-version prerelease publisher; `v0.1.0-recovery.1` was already published on 11 Oct 2026. The release itself is **not deleted** |

The `windows-source-smoke.yml` workflow **still tests PowerShell
launchers, readiness, skill guards and source preparation** but no longer
compiles Relay and AccountServer a second time.

## Active workflow list (14)

| Workflow | Purpose / when it runs |
| --- | --- |
| `admin-web-checks.yml` | PR paths for Web Admin, locale, PAK installer and original UI font fixture; manual |
| `windows-client-ui-regressions.yml` | PR paths for font, bitmap text, Client cursor and UI; manual |
| `windows-combined-build.yml` | PR touching C++/build input: one isolated MSVC x86 build of all **22 native outputs**; manual |
| `windows-pak-extractor.yml` | PR for reader/Engine/build changes; **push to main** for downloadable verified EXE/DLL artifact; manual |
| `windows-staging-runtime.yml` | PR for staged runtime manifests, configs and launcher contracts; manual |
| `windows-runtime-live-evidence.yml` | PR for WORLD_READY, split PAK and diagnostic tools |
| `windows-runtime-preflight.yml` | PR for read-only Windows PE/preflight checks; manual |
| `windows-source-smoke.yml` | PR for source launchers, readiness and skills; no redundant native builds |
| `legacy-source-audit.yml` | PR-wide portable archive tooling, branding and C++98 regression (one run, **not again after merge**) |
| `repository-hygiene-guard.yml` | PR protection: reject newly committed game state, secrets, generated outputs |
| `repository-hygiene.yml` | **Manual** read-only repository inventory |
| `gameplay-code-audit.yml` | Targeted PR / manual gameplay data inventory |
| `quest-content-integrity.yml` | Targeted PR / main-content changes verify quest tables and source contracts |
| `exp-compat-patch.yml` | Targeted PR / EXP table or C++ compatibility changes |

## Trigger policy

- Do **not** automatically repeat the same full build on `push main` if a
  PR already passed the equivalent check. Nine targeted workflows no longer
  repeat after the merge.
- **Exception:** `windows-pak-extractor.yml` retains `push main` so
  `AdminWeb/Install-Pak-Extractor.cmd` can download a **trusted, successful
  main-branch artifact** rather than unreviewed PR executables. Changes
  to HTML or localization alone must not rebuild native PAK tools.
- Heavy source builds are performed once in the **combined build**.
- Every workflow uses read-only or appropriately constrained permissions;
  no pipeline starts live game servers or uploads PAK/player SQL data.
- A changed `on:` trigger does not cancel already-existing historical
  workflow records. Deleted workflow definitions may remain visible in
  GitHub's history for earlier runs.

## Safety before merging

GitHub branch-protection required checks could not be read through the
installed integration (403). If branch settings pin **old job names** as
required status checks, update those settings to the names of the new
combined jobs (`admin-contracts`, `font-and-cursor`,
`fresh-22-binary`) before enforcing future PR merges.

Use `git pull --ff-only origin main` once merged; no local runtime
rebuild/restart is required solely for changing GitHub Actions.
