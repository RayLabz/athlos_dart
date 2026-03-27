import 'dart:io';

/// Represents a TCP client connected to the server.
class TcpClientInfo {
  final InternetAddress address;
  final int port;
  final DateTime connectedAt;

  DateTime lastSeen;

  TcpClientInfo(this.address, this.port)
    : connectedAt = DateTime.now(),
      lastSeen = DateTime.now();

  String get key => '${address.address}:$port';
}
