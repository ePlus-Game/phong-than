# PakEntryExtract for local Web Admin (Windows x86)

The Admin requires the **game's actual PAK item tables**, not only the loose data
in Server/settings/item/001, before allowing item-code actions / item grants.

## Windows distribution without Python or VC6

GitHub Actions workflow: `.github/workflows/windows-pak-extractor.yml`.
It builds a fresh Engine.dll + PakEntryExtract.exe with modern MSVC **outside**
the game runtime. Once the workflow succeeds, download artifact
`phongthan-pak-extractor-win32` from its Actions run and extract both files to:

```
AdminWeb/bin/PakEntryExtract.exe
AdminWeb/bin/Engine.dll
```

Do not copy the bundled Engine.dll to `PhongThanRuntime-Staging/Client` or
`PhongThanRuntime-Staging/Server`. It is an isolated dependency of this tool
only and may be binary-incompatible with the live game DLL.

Restart **only Web Admin** after deployment. Web Admin will attempt to extract
15 tables from the PAKs listed by the live Server/package.ini. It considers
the catalog verified **only if all 15 extractions succeed and are nonempty**.
If any extraction fails or dependencies are missing, Admin can still display
loose tables but **item grants remain blocked**. Do not bypass this guard.

## Verification boundaries

The GitHub Actions job checks the x86 executable builds and starts without
arguments. It does **not** verify the tool against real game PAKs, and does not
certify the game server is WORLD_READY. Only a complete successful live PAK
extraction will unlock item operations on the user's test installation.
