import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../core/net/udp_control_message.dart';
import 'udp_client_info.dart';
import 'udp_server_message_handler.dart';

/// Represents a server.
class UdpServer {

  /// The port of the server.
  final int port;

  /// A callback that will be called when a message is received from a client.
  final UdpServerMessageHandler onMessage;

  /// A callback that will be called periodically to update the server (e.g., for game loops).
  final UdpServerOnTick? onTick;

  /// A callback that will be called when the client starts.
  final Future Function()? onStart;

  /// The interval at which the server will check for inactive clients.
  final Duration tickRate;

  /// The interval at which the server will check for inactive clients.
  final Duration clientTimeout;

  /// The socket used to communicate with the clients.
  late final RawDatagramSocket _socket;

  /// The timer used to schedule the background execution events (game event loop etc.)
  Timer? _tickTimer;

  /// A map of clients connected to the server.
  final Map<String, UdpClientInfo> _clients = {};

  UdpServer({
    required this.port,
    required this.onMessage,
    this.onTick,
    this.onStart,
    this.tickRate = const Duration(milliseconds: 200),
    this.clientTimeout = const Duration(minutes: 1),
  });

  /// Returns the clients connected to the server.
  Iterable<UdpClientInfo> get clients => _clients.values;

  /// Starts the server.
  Future<void> start() async {
    if (onStart != null) await onStart!();

    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);

    _socket.listen(_handleEvent);

    _tickTimer = Timer.periodic(tickRate, (_) {
      _removeInactiveClients();

      if (onTick != null) {
        onTick!(this);
      }
    });
  }

  /// Handles the events from the socket.
  void _handleEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;

    final datagram = _socket.receive();
    if (datagram == null) return;

    final message = Uint8List.fromList(datagram.data);

    final address = datagram.address;
    final port = datagram.port;

    final key = '${address.address}:$port';

    if (UdpControlMessage.isDisconnect(message)) {
      final removed = _clients.remove(key);

      if (removed != null) {
        print('Client disconnected: ${removed.key}');
      }

      return;
    }

    final client = _clients.putIfAbsent( //Create new client if not exists
      key,
      () => UdpClientInfo(address, port),
    );

    if (UdpControlMessage.isHandshake(message)) {
      client.lastSeen = DateTime.now();
      return;
    }

    onMessage(message, address, port);
  }

  /// Removes inactive clients from the server.
  void _removeInactiveClients() {
    final now = DateTime.now();

    _clients.removeWhere((_, client) {
      final inactive = now.difference(client.lastSeen) > clientTimeout;

      if (inactive) {
        print('client timeout: ${client.key}');
      }

      return inactive;
    });
  }

  /// Sends a message to a client.
  void send(Uint8List message, InternetAddress address, int port) {
    _socket.send(message, address, port);
  }

  /// Sends a message to a list of clients.
  void multicast(Uint8List message, List<UdpClientInfo> clients) {
    for (final c in clients) {
      send(message, c.address, c.port);
    }
  }

  /// Broadcasts a message to all clients.
  void broadcast(Uint8List message) {
    for (final c in _clients.values) {
      send(message, c.address, c.port);
    }
  }

  /// Closes the server.
  void close() {
    _tickTimer?.cancel();
    _socket.close();
  }

}
