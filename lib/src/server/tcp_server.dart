import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import '../core/net/network_logger.dart';
import '../core/net/tcp_connection_worker.dart';
import 'tcp_client_info.dart';
import 'tcp_server_message_handler.dart';

/// Represents a TCP server.
class TcpServer {
  /// Logical name of this server instance used in logs.
  final String name;

  /// The port of the server.
  final int port;

  /// A callback that will be called when a framed message is received from a client.
  final TcpServerMessageHandler onMessage;

  /// A callback that will be called periodically to update the server (e.g., for game loops).
  final TcpServerOnTick? onTick;

  /// A callback that will be called when a client connects.
  final TcpServerOnClientConnected? onClientConnected;

  /// A callback that will be called when a client disconnects.
  final TcpServerOnClientDisconnected? onClientDisconnected;

  /// A callback that will be called when the server starts.
  final Future<void> Function()? onStart;

  /// The interval used to invoke [onTick].
  final Duration tickRate;

  /// Maximum allowed framed TCP payload size in bytes.
  final int maxMessageSize;

  /// Logger used by this server.
  final NetworkLogger logger;

  /// The socket used to accept TCP clients.
  late final ServerSocket _serverSocket;

  /// The timer used to schedule background execution events.
  Timer? _tickTimer;

  /// A map of clients connected to the server.
  final Map<String, TcpClientInfo> _clients = {};
  final Map<String, Socket> _sockets = {};
  final Map<String, StreamSubscription<Uint8List>> _socketSubscriptions = {};
  final Map<String, Isolate> _connectionIsolates = {};
  final Map<String, ReceivePort> _connectionReceivePorts = {};
  final Map<String, StreamSubscription<dynamic>> _workerSubscriptions = {};
  final Map<String, SendPort> _workerPorts = {};

  StreamSubscription<Socket>? _serverSubscription;
  bool _isClosed = false;

  TcpServer({
    this.name = 'AthlosTCPServer',
    required this.port,
    required this.onMessage,
    this.onTick,
    this.onClientConnected,
    this.onClientDisconnected,
    this.onStart,
    this.tickRate = const Duration(milliseconds: 200),
    this.maxMessageSize = 8 * 1024 * 1024,
    NetworkLogger? logger,
  }) : logger = logger ?? NetworkLogger();

  /// Returns the clients connected to the server.
  Iterable<TcpClientInfo> get clients => _clients.values;

  /// Starts the server.
  Future<void> start() async {
    if (onStart != null) {
      await onStart!();
    }

    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    _serverSubscription = _serverSocket.listen(_handleClient);
    logger.log(name, 'Started on port $port.');

    if (onTick != null) {
      _tickTimer = Timer.periodic(tickRate, (_) => onTick!(this));
    }
  }

  Future<void> _handleClient(Socket socket) async {
    final client = TcpClientInfo(socket.remoteAddress, socket.remotePort);
    final key = client.key;

    _clients[key] = client;
    _sockets[key] = socket;
    logger.log(name, 'Client connected: ${client.key}');
    onClientConnected?.call(client);

    await _startConnectionWorker(key);

    _socketSubscriptions[key] = socket.listen(
      (Uint8List data) {
        client.lastSeen = DateTime.now();

        final workerPort = _workerPorts[key];
        if (workerPort == null) {
          return;
        }

        workerPort.send({
          'type': 'chunk',
          'data': TransferableTypedData.fromList([Uint8List.fromList(data)]),
        });
      },
      onDone: () => unawaited(_removeClient(key)),
      onError: (_, __) => unawaited(_removeClient(key)),
      cancelOnError: true,
    );
  }

  Future<void> _startConnectionWorker(String key) async {
    final receivePort = ReceivePort();
    final sendPortCompleter = Completer<SendPort>();

    _connectionReceivePorts[key] = receivePort;

    final isolate = await Isolate.spawn(
      tcpConnectionWorkerMain,
      <String, Object?>{
        'sendPort': receivePort.sendPort,
        'maxMessageSize': maxMessageSize,
      },
    );

    _connectionIsolates[key] = isolate;

    _workerSubscriptions[key] = receivePort.listen((dynamic message) {
      if (message is! Map<Object?, Object?>) {
        return;
      }

      final type = message['type'] as String?;
      switch (type) {
        case 'ready':
          final workerPort = message['sendPort'] as SendPort;
          _workerPorts[key] = workerPort;
          if (!sendPortCompleter.isCompleted) {
            sendPortCompleter.complete(workerPort);
          }
        case 'message':
          final client = _clients[key];
          if (client == null) {
            return;
          }

          final payload = (message['data']! as TransferableTypedData)
              .materialize()
              .asUint8List();

          client.lastSeen = DateTime.now();
          onMessage(payload, client);
        case 'protocolError':
          logger.log(
            name,
            'Protocol error for $key: ${message['message']}',
          );
          unawaited(_removeClient(key));
      }
    });

    await sendPortCompleter.future;
  }

  /// Sends a framed message to a client.
  void send(Uint8List message, TcpClientInfo client) {
    final socket = _sockets[client.key];
    if (socket == null) {
      return;
    }

    socket.add(frameTcpMessage(message));
  }

  /// Sends a framed message to a list of clients.
  void multicast(Uint8List message, List<TcpClientInfo> clients) {
    for (final client in clients) {
      send(message, client);
    }
  }

  /// Broadcasts a framed message to all clients.
  void broadcast(Uint8List message) {
    for (final client in _clients.values) {
      send(message, client);
    }
  }

  Future<void> _removeClient(String key) async {
    final client = _clients.remove(key);
    if (client == null) {
      return;
    }

    final socketSubscription = _socketSubscriptions.remove(key);
    await socketSubscription?.cancel();

    final workerPort = _workerPorts.remove(key);
    workerPort?.send({'type': 'close'});

    final workerSubscription = _workerSubscriptions.remove(key);
    await workerSubscription?.cancel();

    _connectionReceivePorts.remove(key)?.close();
    _connectionIsolates.remove(key)?.kill(priority: Isolate.immediate);

    final socket = _sockets.remove(key);
    await socket?.close();

    logger.log(name, 'Client disconnected: ${client.key}');
    onClientDisconnected?.call(client);
  }

  /// Closes the server and all connected clients.
  Future<void> close() async {
    if (_isClosed) {
      return;
    }

    _isClosed = true;
    logger.log(name, 'Closing server.');

    _tickTimer?.cancel();
    await _serverSubscription?.cancel();
    await _serverSocket.close();

    final keys = _clients.keys.toList(growable: false);
    for (final key in keys) {
      await _removeClient(key);
    }
  }
}
