import 'dart:io';
import 'dart:typed_data';

import 'udp_server.dart';

typedef UdpServerMessageHandler =
    void Function(Uint8List message, InternetAddress address, int port);

typedef UdpServerOnTick = void Function(UdpServer server);
