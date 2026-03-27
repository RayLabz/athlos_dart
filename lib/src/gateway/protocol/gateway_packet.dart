import 'dart:convert';
import 'dart:typed_data';

import 'gateway_opcode.dart';

/// Simple JSON envelope used by gateway clients.
class GatewayPacket {
  final GatewayOpcode opcode;
  final Map<String, Object?> data;

  const GatewayPacket({required this.opcode, this.data = const {}});

  Uint8List toBytes() => Uint8List.fromList(
    utf8.encode(jsonEncode({'opcode': opcode.wireValue, 'data': data})),
  );

  static GatewayPacket? tryParse(Uint8List bytes) {
    try {
      final dynamic decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final opcodeValue = decoded['opcode'];
      if (opcodeValue is! String) {
        return null;
      }

      final opcode = GatewayOpcodeWire.fromWireValue(opcodeValue);
      if (opcode == null) {
        return null;
      }

      final rawData = decoded['data'];
      if (rawData != null && rawData is! Map) {
        return null;
      }

      return GatewayPacket(
        opcode: opcode,
        data: (rawData as Map?)?.cast<String, Object?>() ?? const {},
      );
    } catch (_) {
      return null;
    }
  }
}
