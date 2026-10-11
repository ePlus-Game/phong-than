# Refactor roadmap — preserve the original archive

The root \`PhongThanSource/\` and runtime files are a byte-verified copy of
the original ~9 GB PT.zip. Do not reformat, move, overwrite or delete them
during modernization; work through the overlays and a separate copied tree.

## Phase 1 — Network and error-handling

- \`overlays/legacy/GatewayEndpointParser.h\` is a portable C++98 parser for
  the AccountServer gateway's \`IPv4:port\` client-info format.
- \`tools/legacy_hardening.py\` patches an **external copy** of the original
  AccountServer and GameServer sources. Existing packet-size checks and safe
  \`fprintf\` formatting remain enabled.
- \`tests/cpp/test_gateway_endpoint.cpp\` exercises malformed endpoints and
  boundary ports under a host C++98 compiler.
- Python tests check exact patch contexts, idempotency and refusal to overwrite
  incompatible files.

## Next phases

1. Audit packet framing, memory ownership and reconnect flows in AccountServer
   and GameServer; patch only small verified sections.
2. Extract portable components from Client / Server individually without
   modifying public ABI, on-disk formats, network protocol or VC6 project names.
3. Build the copied source in an isolated Windows x86 VM; record compiler errors.
4. Test Client login and map entry against a local isolated Server before
   describing the game as playable.

A green host-parser test does not prove the entire game builds or runs.
