import 'dart:convert';
import 'dart:io';

import 'package:athlos/athlos.dart';

Future<void> main() async {
  // Backends are seeded on first run.  On subsequent runs the gateway
  // reloads them from backend-nodes.dat instead of using these values.
  final seedBackends = [
    BackendNode(id: 'game-a', host: '127.0.0.1', port: 9001),
    BackendNode(id: 'game-b', host: '127.0.0.1', port: 9002),
  ];

  final relay = GatewayRelay(
    authenticator: InMemoryGatewayAuthenticator({
      'dev-token-1': 'player-1',
      'dev-token-2': 'player-2',
    }),
    matchmaker: const DefaultGatewayMatchmaker(),
    loadBalancer: const LeastConnectionsLoadBalancer(),
    ddosGuard: SlidingWindowDdosGuard(
      maxRequests: 120,
      window: const Duration(seconds: 30),
    ),
    backends: seedBackends,
    backendNodeStore: const BackendNodeStore(filePath: 'backend-nodes.dat'),
  );

  final tcpGateway = GatewayTcpServer(port: 7777, relay: relay);
  final udpGateway = GatewayUdpServer(port: 7778, relay: relay);

  // relay.start() is called automatically by the gateway servers.
  await tcpGateway.start();
  await udpGateway.start();

  stdout.writeln('Gateway running on TCP 7777 / UDP 7778.');
  stdout.writeln('Backends: ${relay.backends.map((b) => b.id).join(', ')}');
  stdout.writeln('Commands:');
  stdout.writeln('  add <id> <host> <port>  – register a backend node');
  stdout.writeln('  remove <id>             – unregister a backend node');
  stdout.writeln('  list                    – list active backend nodes');
  stdout.writeln('  quit                    – stop the gateway');

  // Simple REPL for dynamic backend management.
  stdin.lineMode = true;
  stdin.echoMode = true;

  await for (final raw
      in stdin
          .transform(SystemEncoding().decoder)
          .transform(const LineSplitter())) {
    final parts = raw.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) continue;

    switch (parts.first) {
      case 'add':
        if (parts.length < 4) {
          stdout.writeln('Usage: add <id> <host> <port>');
          break;
        }
        final newPort = int.tryParse(parts[3]);
        if (newPort == null) {
          stdout.writeln('Invalid port: ${parts[3]}');
          break;
        }
        await relay.addBackend(
          BackendNode(id: parts[1], host: parts[2], port: newPort),
        );
        stdout.writeln(
          'Added backend ${parts[1]} – total: ${relay.backends.length}',
        );
      case 'remove':
        if (parts.length < 2) {
          stdout.writeln('Usage: remove <id>');
          break;
        }
        await relay.removeBackend(parts[1]);
        stdout.writeln(
          'Removed backend ${parts[1]} – total: ${relay.backends.length}',
        );
      case 'list':
        final nodes = relay.backends.toList();
        if (nodes.isEmpty) {
          stdout.writeln('No backend nodes registered.');
        } else {
          for (final n in nodes) {
            stdout.writeln('  $n');
          }
        }
      case 'quit':
        await tcpGateway.close();
        udpGateway.close();
        exit(0);
      default:
        stdout.writeln('Unknown command: ${parts.first}');
    }
  }
}
