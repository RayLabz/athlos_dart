/// Control opcodes exchanged between clients and gateway servers.
enum GatewayOpcode {
  authenticate,
  authenticated,
  authenticationFailed,
  matchmakingRequest,
  routed,
  routeRequest,
  routeInfo,
  error,
}

extension GatewayOpcodeWire on GatewayOpcode {
  String get wireValue {
    switch (this) {
      case GatewayOpcode.authenticate:
        return 'authenticate';
      case GatewayOpcode.authenticated:
        return 'authenticated';
      case GatewayOpcode.authenticationFailed:
        return 'authenticationFailed';
      case GatewayOpcode.matchmakingRequest:
        return 'matchmakingRequest';
      case GatewayOpcode.routed:
        return 'routed';
      case GatewayOpcode.routeRequest:
        return 'routeRequest';
      case GatewayOpcode.routeInfo:
        return 'routeInfo';
      case GatewayOpcode.error:
        return 'error';
    }
  }

  static GatewayOpcode? fromWireValue(String value) {
    for (final opcode in GatewayOpcode.values) {
      if (opcode.wireValue == value) {
        return opcode;
      }
    }
    return null;
  }
}
