## 0.0.5
Implemented HTTP client and server:

- Added `HttpClient` and `HttpServer` implementations with support for routing and common HTTP methods.
- Introduceed `HttpRequestContext` for simplified response handling (JSON, text, binary).
- Added `Service` abstract class to the core service layer.
- Included examples and tests for HTTP client and server functionality.

## 0.0.4
(a) Implemented TCP Client/Server and introduced logging components (file, console).
- Added `TcpClient` and `TcpServer` implementations with support for framed messages using a 4-byte length prefix.
- Introduced `tcpConnectionWorkerMain` to handle TCP message reassembly in a dedicated isolate.
- Implementd `NetworkLogger` for configurable console and file logging across UDP and TCP components.
- Enhanced `UdpServer` and `UdpClient` with logging and lifecycle callbacks (`onClientConnected`, `onClientDisconnected`).
- Added comprehensive tests for TCP networking, client lifecycle events, and network logging.
- Exported new TCP and logging components in the main library file.

(b) Implementing gateway routing for TCP/UDP:
- Added `GatewayRelay` to orchestrate authentication, matchmaking, and session routing.
- Implemented `GatewayTcpServer` and `GatewayUdpServer` to handle client gateway requests.
- Added pluggable services for authentication (`GatewayAuthenticator`), matchmaking (`GatewayMatchmaker`), load balancing (`GatewayLoadBalancer`), and DDoS protection (`GatewayDdosGuard`).
- Added `BackendNodeStore` for optional file-backed persistence of backend game servers.
- Defined `GatewayPacket` protocol and opcodes for client-gateway communication.
- Updated `athlos.dart` to export new gateway models, services, and runtime classes.
- Added comprehensive tests for `GatewayRelay`, `GatewayTcpServer`, and backend management.
- Provided a functional REPL example for dynamic backend management in `athlos_example.dart`.

## 0.0.3
- Basic UDP Server.

## 0.0.2+1
- Exported API.

## 0.0.2

- Model updates:
  - Achievements
  - Entity types
  - Lobby
  - Logging
  - Monetization
  - Notifications
  - Resources
  - Social (messaging)
  - Other renaming/refactoring.

## 0.0.1+1

- Exported model, made available to consumers.

## 0.0.1

- Initial version.
- Data model (`/core`)
  - Positioning, direction, and orientation models.
  - World model.
  - Session models.
  - Terrain model.
  - State models.
  - Entity model.
  - Action model.
  - Player model.
  - Team model.
  - Leaderboard model.
  
