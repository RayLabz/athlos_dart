import 'dart:typed_data';

import 'tcp_client_info.dart';
import 'tcp_server.dart';

/// A function that is called when a framed message is received from a TCP client.
typedef TcpServerMessageHandler =
    void Function(Uint8List message, TcpClientInfo client);

/// A function that is called periodically to update the server.
typedef TcpServerOnTick = void Function(TcpServer server);

typedef TcpServerOnClientConnected = void Function(TcpClientInfo client);

typedef TcpServerOnClientDisconnected = void Function(TcpClientInfo client);
