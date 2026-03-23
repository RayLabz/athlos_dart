import 'dart:io';

/// Represents a client connected to the server.
class UdpClientInfo {
  final InternetAddress address;
  final int port;

  DateTime lastSeen;

  UdpClientInfo(this.address, this.port) : lastSeen = DateTime.now();

  String get key => '${address.address}:$port';
}
