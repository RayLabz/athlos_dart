import 'dart:typed_data';

/// Special control packets used internally by the server and client to communicate with each other over UDP transport.
abstract final class UdpControlMessage {
  static const List<int> _handshakeBytes = <int>[
    0x41,
    0x54,
    0x48,
    0x4c,
    0x4f,
    0x53,
    0x5f,
    0x48,
    0x53,
    0x4b,
  ];

  static const List<int> _disconnectBytes = <int>[
    0x41,
    0x54,
    0x48,
    0x4c,
    0x4f,
    0x53,
    0x5f,
    0x44,
    0x49,
    0x53,
    0x43,
  ];

  /// Creates a handshake message.
  static Uint8List handshake() => Uint8List.fromList(_handshakeBytes);

  /// Creates a disconnect message.
  static Uint8List disconnect() => Uint8List.fromList(_disconnectBytes);

  /// Checks if a message is a handshake message.
  static bool isHandshake(Uint8List message) =>
      _listEquals(message, _handshakeBytes);

  /// Checks if a message is a disconnect message.
  static bool isDisconnect(Uint8List message) =>
      _listEquals(message, _disconnectBytes);

  /// Checks if two lists of bytes are equal.
  static bool _listEquals(List<int> left, List<int> right) {
    if (identical(left, right)) {
      return true;
    }

    if (left.length != right.length) {
      return false;
    }

    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) {
        return false;
      }
    }

    return true;
  }
}
