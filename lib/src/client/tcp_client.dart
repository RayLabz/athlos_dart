import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import '../core/net/network_logger.dart';
import '../core/net/tcp_connection_worker.dart';
import 'tcp_client_message_handler.dart';

/// Represents a TCP client connected to a server.
class TcpClient {
  /// The address of the server this client will connect to.
  final InternetAddress serverAddress;

  /// The port of the server this client will connect to.
  final int serverPort;

  /// A callback that will be called when a framed message is received from the server.
  final TcpClientMessageHandler onMessage;

  /// A callback that will be called periodically to update the client.
  final TcpClientOnTick? onTick;

  /// A callback that will be called when the client starts.
  final Future<void> Function()? onStart;

  /// The interval used to invoke [onTick].
  final Duration tickRate;

  /// Maximum allowed framed TCP payload size in bytes.
  final int maxMessageSize;

  /// Logger used by this client.
  final NetworkLogger logger;

  /// The socket used to communicate with the server.
  late final Socket _socket;

  /// The timer used to schedule background execution events.
  Timer? _tickTimer;

  ReceivePort? _workerReceivePort;
  StreamSubscription<dynamic>? _workerSubscription;
  StreamSubscription<Uint8List>? _socketSubscription;
  Isolate? _connectionIsolate;
  SendPort? _workerPort;

  bool _isStarted = false;
  bool _isClosed = false;

  TcpClient({
    required this.serverAddress,
    required this.serverPort,
    required this.onMessage,
    this.onTick,
    this.onStart,
    this.tickRate = const Duration(milliseconds: 200),
    this.maxMessageSize = 8 * 1024 * 1024,
    NetworkLogger? logger,
  }) : logger = logger ?? NetworkLogger();

  /// Starts the client.
  Future<void> start() async {
    if (onStart != null) {
      await onStart!();
    }

    _socket = await Socket.connect(serverAddress, serverPort);
    _isStarted = true;
    logger.log(
      'TcpClient',
      'Connected to ${serverAddress.address}:$serverPort.',
    );

    await _startConnectionWorker();

    _socketSubscription = _socket.listen(
      (Uint8List data) {
        final workerPort = _workerPort;
        if (workerPort == null) {
          return;
        }

        workerPort.send({
          'type': 'chunk',
          'data': TransferableTypedData.fromList([Uint8List.fromList(data)]),
        });
      },
      onDone: () => unawaited(close()),
      onError: (_, __) => unawaited(close()),
      cancelOnError: true,
    );

    if (onTick != null) {
      _tickTimer = Timer.periodic(tickRate, (_) => onTick!(this));
    }
  }

  Future<void> _startConnectionWorker() async {
    final receivePort = ReceivePort();
    final sendPortCompleter = Completer<SendPort>();

    _workerReceivePort = receivePort;

    _connectionIsolate = await Isolate.spawn(
      tcpConnectionWorkerMain,
      <String, Object?>{
        'sendPort': receivePort.sendPort,
        'maxMessageSize': maxMessageSize,
      },
    );

    _workerSubscription = receivePort.listen((dynamic message) {
      if (message is! Map<Object?, Object?>) {
        return;
      }

      final type = message['type'] as String?;
      switch (type) {
        case 'ready':
          final workerPort = message['sendPort'] as SendPort;
          _workerPort = workerPort;
          if (!sendPortCompleter.isCompleted) {
            sendPortCompleter.complete(workerPort);
          }
        case 'message':
          final payload = (message['data']! as TransferableTypedData)
              .materialize()
              .asUint8List();
          onMessage(payload);
        case 'protocolError':
          logger.log('TcpClient', 'Protocol error: ${message['message']}');
          unawaited(close());
      }
    });

    await sendPortCompleter.future;
  }

  /// Sends a framed message to the server.
  void send(Uint8List message) {
    if (!_isStarted || _isClosed) {
      return;
    }

    _socket.add(frameTcpMessage(message));
  }

  /// Closes the client and its connection isolate.
  Future<void> close() async {
    if (_isClosed) {
      return;
    }

    _isClosed = true;
    logger.log('TcpClient', 'Closing client.');

    _tickTimer?.cancel();

    await _socketSubscription?.cancel();
    _workerPort?.send({'type': 'close'});
    await _workerSubscription?.cancel();
    _workerReceivePort?.close();
    _connectionIsolate?.kill(priority: Isolate.immediate);

    if (_isStarted) {
      await _socket.close();
    }

    logger.log(
      'TcpClient',
      'Disconnected from ${serverAddress.address}:$serverPort.',
    );
  }
}
