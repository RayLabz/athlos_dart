import 'dart:io';
import 'dart:typed_data';

import 'udp_client_info.dart';
import 'udp_server.dart';

typedef UdpServerMessageHandler =
    void Function(Uint8List message, InternetAddress address, int port);

typedef UdpServerOnTick = void Function(UdpServer server);

typedef UdpServerOnClientConnected = void Function(UdpClientInfo client);

typedef UdpServerOnClientDisconnected = void Function(UdpClientInfo client);
