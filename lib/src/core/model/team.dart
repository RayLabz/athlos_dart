/// A class representing a team in the game, which can be used for team-based gameplay, matchmaking, and account management.
abstract class Team {

  // The ID of the team.
  String id;

  // The ID of the player who is the leader of the team, which can be used for team management and permissions.
  String leaderID;

  // The name of the team, which can be displayed in the UI or used for logging.
  String name;

  // A brief description of the team, which can be displayed in the UI or used for tooltips.
  String description;

  // The timestamp of when the team was created, which can be used for account management and analytics.
  int createdOn = DateTime.now().millisecondsSinceEpoch;

  // The maximum number of players that can be on the team, which can be used for matchmaking and team management.
  int playerLimit;

  // A list of player IDs that are members of the team, which can be used for team-based gameplay and matchmaking.
  List<String> playerIDs;

  Team({
    required this.id,
    required this.leaderID,
    required this.name,
    required this.description,
    required this.playerLimit,
    required this.playerIDs
  });
}
