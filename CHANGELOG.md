## 0.0.4
- Added `TcpClient` and `TcpServer` implementations with support for framed messages using a 4-byte length prefix.
- Introduced `tcpConnectionWorkerMain` to handle TCP message reassembly in a dedicated isolate.
- Implementd `NetworkLogger` for configurable console and file logging across UDP and TCP components.
- Enhanced `UdpServer` and `UdpClient` with logging and lifecycle callbacks (`onClientConnected`, `onClientDisconnected`).
- Added comprehensive tests for TCP networking, client lifecycle events, and network logging.
- Exported new TCP and logging components in the main library file.

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
  
