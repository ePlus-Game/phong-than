# Web Admin Workspace v2

## Goal
Modernize the local-only `http://localhost:8765/` administration UI without
altering queued Lua actions, SQL LocalDB schemas, inventory identifiers, or
critical server/character state.

## Consolidated workspaces

| Workspace | Screens still available |
| --- | --- |
| Tổng quan | Tổng quan, Lịch sử lệnh |
| Người chơi | Tài khoản, Quản lý nhân vật |
| Phát thưởng | Phát đồ, Kỹ năng, Thú cưỡi, Quà & thành tích |
| Trang bị | Đồ lục, Vũ khí lục, Đồ max/pháp bảo, Cường hóa |
| Thế giới | Boss/NPC, Boss thế giới, Vạn Tiên trận, Mật độ/hồi quái |
| Bot & tổ đội | Bot giả người chơi, Tổ đội bot |
| Sự kiện | Thông báo, Sự kiện, Lịch sự kiện |
| Hệ thống | Sức khỏe server, Sao lưu/khôi phục, Cài đặt server |

All **24 existing section IDs**, `data-t` navigation buttons and existing
event handlers remain. Sidebar search finds individual screens, workspace
tabs provide contextual navigation, and `#section-id` URLs allow opening a
specific screen. On mobile, the sidebar becomes a dismissible drawer.

### Consolidated actions
The Give/Phát đồ panel now has **one lệnh-bài selector** instead of 12
individual action buttons. These old buttons are kept in the DOM (hidden)
with their original `onclick` handlers, and the consolidated control simply
calls the selected original button, so existing API payloads are untouched.

### PAK verification
The read-only `/api/status` response now includes
`status.itemCatalogVerified` from the same original `PakVerified` value
used by the server-side restriction. The Give panel clearly indicates
whether item grants are locked. **The server remains the authority**:
nothing in the UI unlocks grant actions.

### Overview
Four status cards show counts from `/api/status`: running services out of
five, online player count, Lua bridge heartbeat freshness, and pending queue
presence. A running process count is **not** proof of Bishop 102-map
`WORLD_READY`. The UI does not claim the world is ready.

## Testing
`node --test tests/admin_workspace.test.cjs` validates all 24 screens,
no duplicate IDs, JS syntax, grouping coverage, token action references,
and safe PAK status. Windows CI also parses the PowerShell server script.
No actual game SQL, PAK or running server is accessed in CI.

## Deploy to Windows
After merging, `git pull --ff-only origin main` from a clean, checked
local checkout updates the HTML and PowerShell Web Admin script. Restart
**only the Web Admin process** to pick up the new template and route data.
Do **not** restart or overwrite running SQL/Bishop/GameServer services.

The shipped web template uses only standard HTML/CSS/JS; no npm install,
CDN, Python, framework build or browser-extension dependency is required.

## Acceptance
- On PC: 8 workspace headings, quick sub-tabs, clear responsive cards.
- On mobile: single Menu button opens an accessible dismissible sidebar.
- Direct URL `/#accounts` opens the account panel; back/other direct
  hashes operate on existing `data-t` IDs without changing API actions.
- Search returns matching navigation entries and clears on navigation.
- Account creation, action history, backups and all remaining screens
  still use their original request handlers.
- Item grants remain locked if catalog verification fails.
