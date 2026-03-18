# Multiplayer Framework Data Models

## Core Game Domain

~~- **Game**  
  Defines a game type (ruleset, logic bindings, supported modes).~~

- **GameConfig**  
  Static configuration for a game (max players, rules, time limits).

- **GameMode**  
  Variant of a game (ranked, casual, blitz, custom rules).

~~- **GameState**  
  The authoritative, serializable state of a running game instance.~~

~~- **GameSnapshot**  
  A full capture of GameState at a specific point in time.~~

- **GameTick**  
  A discrete simulation step (used in real-time or lockstep systems).

~~- **GameEvent**  
  A domain event emitted during gameplay (e.g., “player eliminated”).~~

~~- **GameAction**  
  A player-initiated command that mutates game state.~~

- **ActionResult**  
  Outcome of processing an action (success, failure, side effects).

- **GameReducer**  
  Deterministic logic that transforms state based on actions.

~~- **GameSession**  
  Runtime container binding players, state, and lifecycle.~~

---

## Player Domain

~~- **Player**  
  Core identity of a user within the system.~~

~~- **PlayerProfile**  
  Public-facing player data (username, avatar, metadata).~~

- **PlayerStats**  
  Aggregated gameplay statistics (wins, losses, rating).

- **PlayerSettings**  
  Preferences (controls, notifications, privacy).

- **PlayerPresence**  
  Real-time availability state (online, offline, in-game).

- **PlayerSession**  
  Authenticated session instance (token, expiry, device).

- **PlayerConnection**  
  Active network connection (WebSocket, peer link).

---

## Matchmaking & Sessions

- **Match**  
  A fully instantiated game instance with participants.

- **MatchConfig**  
  Rules and parameters for a specific match.

- **MatchState**  
  Lifecycle state (waiting, active, completed).

- **MatchResult**  
  Final outcome (scores, winners, rankings).

- **MatchParticipant**  
  Player’s role and state within a match.

- **MatchHistory**  
  Persisted record of completed matches.

- **Queue**  
  A matchmaking pool grouping players by criteria.

- **QueueEntry**  
  A player’s entry in a matchmaking queue.

- **MatchmakingRequest**  
  Input describing desired match conditions.

- **MatchmakingTicket**  
  Server-issued handle tracking matchmaking progress.

---

## Lobby System

- **Lobby**  
  Pre-game room where players gather before a match.

- **LobbyConfig**  
  Settings for a lobby (visibility, max players, rules).

- **LobbyMember**  
  Player’s state within a lobby (ready, host, spectator).

- **LobbyState**  
  Current status of the lobby (open, full, starting).

- **LobbyInvite**  
  Invitation sent to players to join a lobby.

- **LobbyMessage**  
  Message exchanged within a lobby context.

---

## Networking & Sync

- **SyncMessage**  
  Generic network payload for state or commands.

- **SyncState**  
  Client-side representation of synchronized game state.

- **SyncSnapshot**  
  Full state sync used for recovery or initialization.

- **StateDelta**  
  Incremental change applied to state (diff-based sync).

- **ClientCommand**  
  Action sent from client to server.

- **ServerCommand**  
  Instruction or update sent from server to client.

- **ConnectionState**  
  Status of network link (connected, reconnecting, lost).

- **TransportPacket**  
  Low-level serialized network message.

- **Heartbeat**  
  Periodic signal to maintain or verify connection.

---

## Leaderboards & Rankings

- **Leaderboard**  
  Definition of a ranking board (rules, scope, sorting).

- **LeaderboardEntry**  
  A player’s ranked position and score.

- **LeaderboardSeason**  
  Time-bounded leaderboard instance (for resets).

- **LeaderboardConfig**  
  Parameters controlling ranking logic.

- **Ranking**  
  Computed ordering of players based on scores.

- **ScoreRecord**  
  A submitted score instance tied to an event or match.

- **ScoreHistory**  
  Historical log of score changes over time.

---

## Achievements & Progression

- **Achievement**  
  Definition of a goal or milestone.

- **PlayerAchievement**  
  Player-specific achievement state (unlocked, progress).

- **AchievementProgress**  
  Incremental tracking toward completion.

- **Reward**  
  Incentive granted (currency, badge, unlockable).

- **ProgressionTrack**  
  Structured progression path (levels, tiers).

- **Level**  
  Discrete progression milestone.

---

## Social System

- **Friend**  
  Relationship between two players.

- **FriendRequest**  
  Pending request to establish friendship.

- **BlockedPlayer**  
  Player excluded from interaction.

- **Party**  
  Temporary group of players joining matches together.

- **PartyMember**  
  Player’s role/state within a party.

- **Invite**  
  Generic invitation (party, game, lobby).

---

## Chat & Communication

- **ChatChannel**  
  Logical communication space (global, lobby, private).

- **ChatMessage**  
  Message sent between participants.

- **ChatParticipant**  
  Player’s membership in a chat channel.

- **MessageAttachment**  
  Media or data attached to messages.

- **TypingIndicator**  
  Real-time signal indicating message composition.

---

## Persistence & Storage

- **StoredGameState**  
  Persisted version of a game state.

- **SnapshotRecord**  
  Stored snapshot for rollback or recovery.

- **EventLog**  
  Chronological record of system or gameplay events.

- **ActionLog**  
  Sequence of actions applied to a game.

- **AuditLog**  
  Record of critical system changes for traceability.

---

## Analytics & Logging

- **AnalyticsEvent**  
  Structured event for tracking user or system behavior.

- **Metric**  
  Aggregated measurement (DAU, match duration, etc.).

- **SessionLog**  
  Record of player session activity.

- **ErrorLog**  
  Captured system or runtime errors.

- **TelemetryRecord**  
  Low-level performance or usage data.

---

## Anti-Cheat & Validation

- **ValidationRule**  
  Rule used to verify action or state integrity.

- **Violation**  
  Detected breach of rules.

- **CheatReport**  
  Report generated from suspicious behavior.

- **TrustScore**  
  Heuristic score representing player reliability.

---

## Monetization (Optional)

- **Currency**  
  Virtual or real currency definition.

- **Wallet**  
  Player’s balance and holdings.

- **Transaction**  
  Record of currency movement.

- **Purchase**  
  Item or service bought by a player.

- **Offer**  
  Available purchasable bundle or promotion.

---

## System / Infrastructure

- **ServiceConfig**  
  Configuration for backend services.

- **FeatureFlag**  
  Toggle controlling feature availability.

- **RateLimit**  
  Constraints on request frequency.

- **Notification**  
  Message sent to player outside gameplay.

- **NotificationPreference**  
  Player’s notification settings.

---

## Optional Advanced Models

- **Replay**  
  Reconstructable record of a match.

- **ReplayFrame**  
  Single frame/state within a replay timeline.

- **SpectatorSession**  
  Non-participant observing a match.

- **BotPlayer**  
  AI-controlled player instance.

- **AIAction**  
  Action generated by AI logic.