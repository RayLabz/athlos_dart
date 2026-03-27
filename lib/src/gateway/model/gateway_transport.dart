/// Transport used by a gateway session.
enum GatewayTransport { tcp, udp }

extension GatewayTransportWire on GatewayTransport {
  String get wireValue => this == GatewayTransport.tcp ? 'tcp' : 'udp';
}
