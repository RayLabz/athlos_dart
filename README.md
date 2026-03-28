The `athlos` package helps model multiplayer online games (and backends) by defining a data model and various behaviors and tools.

> [!IMPORTANT]
> The package is currently under development. Source code and documentation are not yet available.
> For questions, requests, or issues, please contact raylabzg@gmail.com

## Indicative Features

* Game state definition
* Server creation
* Online state sync (multiple methods)
* Data persistence
* Matchmaking, Lobbies & Host management
* Achievements
* Leaderboards
* Player profiles, friend system, game invites
* Action logging
* Chat & Presence
* Different types of games (turn-based, casual real-time, board games, puzzles, etc.)

## Gateway / Relay Baseline

Athlos now includes a baseline gateway routing layer:

* `client -> gateway -> game server`
* Authentication via pluggable `GatewayAuthenticator`
* Matchmaking via pluggable `GatewayMatchmaker`
* Load balancing via pluggable `GatewayLoadBalancer`
* Session routing via `GatewaySessionRouter`
* Basic DDoS/rate limiting via `GatewayDdosGuard`

The gateway can be exposed over TCP (`GatewayTcpServer`) and UDP (`GatewayUdpServer`),
and returns backend route information + session IDs to clients.

## HTTP Server

Athlos also includes a lightweight HTTP server with method/path routing:

* Register handlers with `get`, `post`, `put`, `patch`, `delete`, or `route`.
* Route by URL path and HTTP method.
* Built-in JSON/text response helpers via `HttpRequestContext`.
* Default `404` and `405` responses, plus optional custom not-found handler.

See `example/http_server_example.dart` for a minimal runnable setup.

