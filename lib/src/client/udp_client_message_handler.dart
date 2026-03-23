import 'dart:typed_data';

import 'udp_client.dart';

/// A function that is called when a message is received from the server.
typedef UdpClientMessageHandler = void Function(Uint8List message);

/// A function that is called periodically to update the client.
typedef UdpClientOnTick = void Function(UdpClient client);
