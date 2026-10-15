# Web Admin test coverage

Updated: 2026-10-15. Scope: production JavaScript/PowerShell functions with isolated fixtures. This is not live game acceptance.

## Execution

- `node --test tests/admin_workspace.test.cjs tests/admin_locale.test.cjs tests/admin_behavior.test.cjs`
- Windows PowerShell 5.1: `powershell -NoProfile -File tests/Test-AdminBehavior.ps1`
- Windows PowerShell 5.1: `powershell -NoProfile -File tests/Test-AdminFeatures.ps1`
- All run in `.github/workflows/admin-web-checks.yml`.

The feature suite imports selected production AST functions, not the server entry point. File round trips run under a GUID directory in OS temp and remove that directory afterwards. SQL, account-registration service and process-launch boundaries are mocks. Lua output is inspected, not executed by CoreServer.

## Coverage by screen

| Screen | Automated checks | Still needs live acceptance |
|---|---|---|
| overview | Service/player metrics, missing heartbeat, pending queue | Real process/bridge freshness |
| give | Catalog lookup, PAK rejection, recipient/count, give/all command | Actual item received and runtime catalog IDs |
| skills | Profession filter, duplicates, limits, level preservation, attributes, books and Than Ky modes | Actual skills/points in game |
| mounts | Catalog search/class filtering/deduplication; common give dispatch | Mounted appearance and item behavior |
| gear | Set grouping, common give dispatch | Full set received/equipped |
| weapons | Profession/tier/green filter; common give dispatch | Item stats and equip behavior |
| maxgear | Shared item dispatch; screen/navigation contracts | Preset catalog accuracy and every preset |
| upgrade | Inventory status parsing, command bounds, invalid/fractional IDs | Game item upgrade result |
| boss | Catalog IDs including sparse IDs, invalid maps/NPCs, near-player/map commands, clear | Spawn position, visibility and cleanup |
| worldboss | Known/unknown keys, live status fixture/killer/time parsing | Actual spawn/death/respawn |
| vantien | Instance bounds, open command, state/kill-mask parsing | Entry, preparation and combat |
| bots | Save/read/replace/disable, map guards and live count parsing | Movement, cleanup, server cap |
| matdo | Save/read, multiplier/revive limits, map selection and live state | Actual monster density and revive |
| evsched | Save/read, duplicate IDs, next-run windows and overlap warnings | Minute timer firing |
| dailygift | Save/read, VNG tuple conversion, invalid group, achievement status | Actual reward/streak/claim behavior |
| news | Trim, limits, Lua escaping and queued command | In-game broadcast display |
| events | Form payload, time validation, unique IDs, invalid legacy rows | Real scheduled command execution |
| accounts | SecureString registration boundary, password hash/SQL parameters, currency bounds and missing account | Real LocalDB writes and login |
| health | Allowlisted log tail, missing log and traversal rejection | Real binary/PAK/process diagnostics |
| backups | Synthetic character backup/restore and deployment rollback with safety copy/hash | Real deployment and account DB backup |
| chars | Online/stale guards, valid fixture checksums, soft-delete/undelete byte round trip, traversal rejection | Live character disappearance/relogin and concurrent sessions |
| botparty | Save/read, duplicate names, weighted class selection and live counts | In-game party composition/EXP |
| history | Real pending-file append and history persistence; result-log application | CoreServer consumes queue and reports result |
| setup | Unsupported/concurrent-step rejection before launch | Actual LocalDB/server installer and process launch |

## Regressions reproduced and fixed during the feature run

The first feature run produced 76 passes and seven failures:
1. Fractional equipment IDs were rounded.
2. NPC spawn accepted a map outside the loaded catalog.
3. Sparse NPC catalog IDs were replaced by array indexes.
4. An unknown NPC ID silently selected another NPC.
5. Expanding a chest modified the character file while the player was online.
6. Client resolution readback read keys from unrelated INI sections.
7. Saving resolution without an existing Client section wrote keys into the wrong section.

Tests now require strict equipment IDs, exact NPC lookup, valid map/mode, correct online-player envelope, and section-scoped client config reads/writes. Offline chest editing also uses the existing online/freshness guard.
