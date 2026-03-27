import 'dart:typed_data';

import 'package:athlos/src/client/tcp_client.dart';

/// A function that is called when a framed message is received from the TCP server.
typedef TcpClientMessageHandler = void Function(Uint8List message);

/// A function that is called periodically to update the client.
typedef TcpClientOnTick = void Function(TcpClient client);
