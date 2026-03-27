import '../model/backend_node.dart';

/// Selects a backend node for new sessions.
abstract class GatewayLoadBalancer {
  BackendNode? selectNode(String poolId, Iterable<BackendNode> nodes);
}

/// Selects the least loaded backend with available capacity.
class LeastConnectionsLoadBalancer implements GatewayLoadBalancer {
  const LeastConnectionsLoadBalancer();

  @override
  BackendNode? selectNode(String poolId, Iterable<BackendNode> nodes) {
    BackendNode? best;

    for (final node in nodes) {
      if (!node.hasCapacity) {
        continue;
      }

      if (best == null || node.activeSessions < best.activeSessions) {
        best = node;
      }
    }

    return best;
  }
}
