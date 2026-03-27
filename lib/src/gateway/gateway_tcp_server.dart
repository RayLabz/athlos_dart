import 'dart:typed_data';

import '../server/tcp_client_info.dart';
import '../server/tcp_server.dart';
import 'gateway_relay.dart';
import 'model/gateway_transport.dart';
import 'protocol/gateway_opcode.dart';
import 'protocol/gateway_packet.dart';

/// Gateway endpoint that accepts TCP clients and returns routing decisions.
class GatewayTcpServer {
  final TcpServer server;
  final GatewayRelay relay;

  GatewayTcpServer._({required this.server, required this.relay});

  factory GatewayTcpServer({required int port, required GatewayRelay relay}) {
    late final TcpServer server;

    server = TcpServer(
      name: 'AthlosGatewayTCP',
      port: port,
      onMessage: (message, client) {
        _handleMessage(
          server: server,
          relay: relay,
          client: client,
          bytes: message,
        );
      },
      onClientDisconnected: (client) {
        relay.disconnect(client.key);
      },
      logger: relay.logger,
    );

    return GatewayTcpServer._(server: server, relay: relay);
  }

  Future<void> start() async {
    await relay.start();
    await server.start();
  }

  Future<void> close() => server.close();

  static void _handleMessage({
    required TcpServer server,
    required GatewayRelay relay,
    required TcpClientInfo client,
    required Uint8List bytes,
  }) {
    final packet = GatewayPacket.tryParse(bytes);

    if (packet == null) {
      server.send(
        GatewayPacket(
          opcode: GatewayOpcode.error,
          data: {'message': 'Invalid packet.'},
        ).toBytes(),
        client,
      );
      return;
    }

    switch (packet.opcode) {
      case GatewayOpcode.authenticate:
        final token = packet.data['token'] as String?;
        if (token == null || token.isEmpty) {
          _sendError(server, client, 'Token is required.');
          return;
        }

        relay.authenticate(clientKey: client.key, token: token).then((result) {
          if (!result.ok) {
            server.send(
              GatewayPacket(
                opcode: GatewayOpcode.authenticationFailed,
                data: {'message': result.error},
              ).toBytes(),
              client,
            );
            return;
          }

          server.send(
            GatewayPacket(
              opcode: GatewayOpcode.authenticated,
              data: {'playerId': result.playerId},
            ).toBytes(),
            client,
          );
        });
      case GatewayOpcode.matchmakingRequest:
        relay
            .createOrRefreshRoute(
              clientKey: client.key,
              transport: GatewayTransport.tcp,
            )
            .then((result) {
              if (!result.ok || result.route == null) {
                _sendError(server, client, result.error ?? 'Routing failed.');
                return;
              }

              server.send(_routePacket(result.route!).toBytes(), client);
            });
      case GatewayOpcode.routeRequest:
        final sessionId = packet.data['sessionId'] as String?;
        if (sessionId == null || sessionId.isEmpty) {
          _sendError(server, client, 'sessionId is required.');
          return;
        }

        final result = relay.routeInfo(sessionId);
        if (!result.ok || result.route == null) {
          _sendError(server, client, result.error ?? 'Route not found.');
          return;
        }

        server.send(_routePacket(result.route!).toBytes(), client);
      default:
        _sendError(
          server,
          client,
          'Unsupported opcode for TCP gateway: ${packet.opcode.wireValue}',
        );
    }
  }

  static GatewayPacket _routePacket(route) {
    return GatewayPacket(
      opcode: GatewayOpcode.routed,
      data: {
        'sessionId': route.session.id,
        'playerId': route.session.playerId,
        'backend': {
          'id': route.backend.id,
          'host': route.backend.host,
          'port': route.backend.port,
        },
      },
    );
  }

  static void _sendError(
    TcpServer server,
    TcpClientInfo client,
    String message,
  ) {
    server.send(
      GatewayPacket(
        opcode: GatewayOpcode.error,
        data: {'message': message},
      ).toBytes(),
      client,
    );
  }
}
