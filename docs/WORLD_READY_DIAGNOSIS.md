# WORLD_READY diagnosis on Windows (read only)

The five services starting is not proof that Bishop registered all 102 maps.
This tool collects safe categorical observations; it **never unlocks login**.
See Issue #71: https://github.com/ePlus-Game/phong-than-truyen-ky/issues/71

## Run without restarting server or touching SQL

From the repository root in Windows PowerShell, after pulling the merged PR:

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\Diagnose-WorldRegistration.ps1 -RuntimeRoot ".\PhongThanRuntime-Staging" -ReportPath "$env:TEMP\phongthan-world-diagnosis.json"

Share only the report JSON from your Windows temporary folder. The report has
no raw lines of game logs, SQL credentials, players or network addresses.

For actual live readiness verification, also run:

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\Read-WindowsRuntimeEvidence.ps1 -RuntimeRoot ".\PhongThanRuntime-Staging" -ManifestPath ".\PhongThanSource\Deploy\RUNTIME_CONTENT_MANIFEST.json" -ExpectedMapCount 102

The live checker requires matching fresh Bishop PID, Relay ServiceId, 102-map
registration, 5 correct process paths and ownership of all required ports.
Exit code 2 means BLOCKED, not a reason to reset the database.

## What the classification indicates

- MAP_PROGRESS_PARTIAL_OR_STALE: less than 102 map slots in observed tail;
  verify loader log freshness before concluding maps are missing.
- GAMESERVER_REGISTRATION_FAILED: GameServer world hello/map registry failed.
- BISHOP_REJECTED_HANDSHAKE_OR_MAPS: Bishop rejected hello or map registration.
- REGISTRY_ACCEPTED_BUT_NO_MARKER: registry accepted; ready marker not found.
- BISHOP_CANNOT_WRITE_READY_MARKER: check log directory write permissions.
- HISTORICAL_WORLD_READY_MARKER_PRESENT: old marker only, NOT live readiness.
- MAPS_OBSERVED_WAITING_FOR_REGISTRATION: map load observed, handshake pending.
- INSUFFICIENT_LOG_EVIDENCE: check log availability and binary version.

## Changed code

- Core KSubWorldSet: correct literal escaped newline in map diagnostic log.
- GameServer KSOServer: record bounded, nonsecret gateway registry stage names.
- Bishop GameServer: record stage-only hello, map registration and marker errors.
- PowerShell diagnostic: bounded, read-only log analysis plus synthetic tests.

New native log events require binaries rebuilt from this commit. The tool
can still analyze old logs, including the historical literal backslash-n
format, but results may be incomplete without newly built binaries. Never
copy new DLL/EXE over a currently running game; test a separate runtime.
CI validates source/tests, not Windows gameplay or login/save/relogin.
