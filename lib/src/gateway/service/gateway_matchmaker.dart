/// Matches a player into a routing pool identifier.
abstract class GatewayMatchmaker {
  Future<String> resolvePool(String playerId);
}

/// Baseline matchmaker: every player enters the default pool.
class DefaultGatewayMatchmaker implements GatewayMatchmaker {
  const DefaultGatewayMatchmaker();

  @override
  Future<String> resolvePool(String playerId) async => 'default';
}
