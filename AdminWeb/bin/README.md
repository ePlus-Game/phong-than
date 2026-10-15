# Bundled PAK reader

This source checkout includes the official Windows x86 reader and its matching
Engine.dll and LuaLibDll.dll. No GitHub CLI or artifact download is required for
normal installation. Build origin and SHA-256 hashes are in provenance.json.

Run AdminWeb\Install-Pak-Extractor.cmd from Explorer to audit all 15 actual server
PAK tables. Web Admin also extracts and verifies them on every startup. Merely
having these binaries does not mark the catalog verified. Missing or unreadable
tables keep item grants locked.

Keep all three files together. Do not copy these DLLs into Client or Server.
The reader is built with MSVC /MD and requires a compatible Microsoft Visual C++
x86 runtime installed on Windows. The bundled reader is not a copy of game data.

To update, use a reviewed successful main run of windows-pak-extractor.yml and
replace all three binaries together, updating provenance.json. Explicit -ZipPath
or -RunId installer arguments override the bundled reader.
