/// Authenticates client-provided tokens.
abstract class GatewayAuthenticator {
  Future<String?> authenticate(String token);
}

/// Minimal in-memory authenticator for local development.
class InMemoryGatewayAuthenticator implements GatewayAuthenticator {
  final Map<String, String> tokenToPlayerId;

  InMemoryGatewayAuthenticator(this.tokenToPlayerId);

  @override
  Future<String?> authenticate(String token) async => tokenToPlayerId[token];
}
