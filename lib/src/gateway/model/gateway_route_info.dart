import 'backend_node.dart';
import 'gateway_session.dart';

/// Route information returned to clients for server handoff.
class GatewayRouteInfo {
  final GatewaySession session;
  final BackendNode backend;

  const GatewayRouteInfo({required this.session, required this.backend});
}
