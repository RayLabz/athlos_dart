import 'dart:isolate';
import 'dart:typed_data';

const String _commandTypeKey = 'type';
const String _commandDataKey = 'data';
const String _commandSendPortKey = 'sendPort';
const String _commandMaxMessageSizeKey = 'maxMessageSize';

const String _commandTypeReady = 'ready';
const String _commandTypeChunk = 'chunk';
const String _commandTypeClose = 'close';
const String _commandTypeMessage = 'message';
const String _commandTypeProtocolError = 'protocolError';

/// Frames a TCP payload using a 4-byte big-endian length prefix.
Uint8List frameTcpMessage(Uint8List payload) {
  final framed = Uint8List(payload.length + 4);
  final header = ByteData.sublistView(framed, 0, 4);
  header.setUint32(0, payload.length, Endian.big);
  framed.setRange(4, framed.length, payload);
  return framed;
}

/// Dedicated connection worker used to reassemble framed TCP messages.
void tcpConnectionWorkerMain(Map<String, Object?> configuration) {
  final mainSendPort = configuration[_commandSendPortKey]! as SendPort;
  final maxMessageSize = configuration[_commandMaxMessageSizeKey]! as int;

  final receivePort = ReceivePort();
  mainSendPort.send({
    _commandTypeKey: _commandTypeReady,
    _commandSendPortKey: receivePort.sendPort,
  });

  final buffer = <int>[];

  receivePort.listen((dynamic message) {
    if (message is! Map<Object?, Object?>) {
      return;
    }

    final type = message[_commandTypeKey] as String?;

    switch (type) {
      case _commandTypeChunk:
        final data = (message[_commandDataKey]! as TransferableTypedData)
            .materialize()
            .asUint8List();
        buffer.addAll(data);
        _emitMessages(mainSendPort, buffer, maxMessageSize);
      case _commandTypeClose:
        receivePort.close();
    }
  });
}

void _emitMessages(
  SendPort mainSendPort,
  List<int> buffer,
  int maxMessageSize,
) {
  while (buffer.length >= 4) {
    final headerBytes = Uint8List.fromList(buffer.sublist(0, 4));
    final messageLength = ByteData.sublistView(
      headerBytes,
    ).getUint32(0, Endian.big);

    if (messageLength > maxMessageSize) {
      mainSendPort.send({
        _commandTypeKey: _commandTypeProtocolError,
        'message': 'TCP message exceeds configured maxMessageSize.',
      });
      buffer.clear();
      return;
    }

    final frameLength = messageLength + 4;
    if (buffer.length < frameLength) {
      return;
    }

    final payload = Uint8List.fromList(buffer.sublist(4, frameLength));
    buffer.removeRange(0, frameLength);

    mainSendPort.send({
      _commandTypeKey: _commandTypeMessage,
      _commandDataKey: TransferableTypedData.fromList([payload]),
    });
  }
}
