import 'gateway_transport.dart';

/// Represents a routed player session managed by the gateway.
class GatewaySession {
  final String id;
  final String clientKey;
  final String playerId;
  final String backendId;
  final GatewayTransport transport;
  final DateTime createdAt;

  DateTime lastSeen;

  GatewaySession({
    required this.id,
    required this.clientKey,
    required this.playerId,
    required this.backendId,
    required this.transport,
    DateTime? createdAt,
    DateTime? lastSeen,
  }) : createdAt = createdAt ?? DateTime.now(),
       lastSeen = lastSeen ?? DateTime.now();
}
