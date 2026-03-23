import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../core/net/udp_control_message.dart';
import 'udp_client_message_handler.dart';

/// Represents a client connected to the server.
class UdpClient {

  /// The address of the server this client will connect to.
  final InternetAddress serverAddress;

  /// The port of the server this client will connect to.
  final int serverPort;

  /// A callback that will be called when a message is received from the server.
  final UdpClientMessageHandler onMessage;

  /// A callback that will be called periodically to update the client.
  final UdpClientOnTick? onTick;

  /// A callback that will be called when the client starts.
  final Future Function()? onStart;

  /// The interval at which the client will send a handshake message to the server.
  final Duration tickRate;

  /// The interval at which the client will send a handshake message to the server.
  final Duration handshakeInterval;

  /// The socket used to communicate with the server.
  late final RawDatagramSocket _socket;

  /// The timer used to schedule the background execution events (game event loop etc.)
  Timer? _tickTimer;

  /// The timer used to schedule the handshake.
  Timer? _handshakeTimer;

  /// Whether the client has started.
  bool _isStarted = false;

  /// Whether the client has been closed.
  bool _isClosed = false;

  UdpClient({
    required this.serverAddress,
    required this.serverPort,
    required this.onMessage,
    this.onTick,
    this.onStart,
    this.tickRate = const Duration(milliseconds: 200),
    this.handshakeInterval = const Duration(minutes: 1),
  });

  /// Starts the client.
  Future<void> start() async {
    if (onStart != null) await onStart!();
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    _isStarted = true;

    _socket.listen(_handleEvent);
    _scheduleHandshake();

    if (onTick != null) {
      _tickTimer = Timer.periodic(tickRate, (_) => onTick!(this));
    }
  }

  /// Schedules the handshake timer & behavior.
  void _scheduleHandshake() {
    _handshakeTimer = Timer.periodic(handshakeInterval, (_) {
      if (_isClosed) {
        return;
      }
      send(UdpControlMessage.handshake());
    });
  }

  /// Handles the events from the socket.
  void _handleEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;

    final datagram = _socket.receive();
    if (datagram == null) return;

    onMessage(Uint8List.fromList(datagram.data));
  }

  /// Sends a message to the server.
  void send(Uint8List message) {
    _socket.send(message, serverAddress, serverPort);
  }

  /// Closes the client.
  void close() {
    disconnect();
  }

  /// Disconnects the client from the server.
  void disconnect() {
    if (_isClosed) {
      return;
    }

    if (_isStarted) {
      send(UdpControlMessage.disconnect());
    }

    _closeSocket();
  }

  /// Closes the socket.
  void _closeSocket() {
    if (_isClosed) {
      return;
    }

    _isClosed = true;

    _handshakeTimer?.cancel();
    _tickTimer?.cancel();

    if (_isStarted) {
      _socket.close();
    }
  }

}
