import 'package:athlos/src/core/model/lobby/lobby_status.dart';

/// Represents a lobby for a world (pre-start).
abstract class Lobby {

  /// The ID of the lobby.
  String id;

  /// The ID of the world associated with the lobby.
  String worldID;

  /// The player limit of the lobby. Set to -1 for infinite.
  int playerLimit;

  /// The lobby password.
  String password;

  /// The status of the lobby.
  LobbyStatus status;

  // A list of IDs for players that are waiting to join the world.
  List<String> waitingPlayerIDsQueue = [];

  Lobby({
    required this.id,
    required this.worldID,
    required this.playerLimit,
    required this.password,
    this.status = LobbyStatus.open,
  });

}
