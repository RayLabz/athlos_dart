import 'dart:collection';

/// DDoS/rate-limit gate run before expensive gateway operations.
abstract class GatewayDdosGuard {
  bool allowRequest(String clientKey);
}

/// Sliding-window in-memory limiter.
class SlidingWindowDdosGuard implements GatewayDdosGuard {
  final int maxRequests;
  final Duration window;
  final Map<String, Queue<DateTime>> _requestTimes = {};

  SlidingWindowDdosGuard({
    this.maxRequests = 120,
    this.window = const Duration(seconds: 30),
  });

  @override
  bool allowRequest(String clientKey) {
    final now = DateTime.now();
    final queue = _requestTimes.putIfAbsent(clientKey, Queue<DateTime>.new);

    while (queue.isNotEmpty && now.difference(queue.first) > window) {
      queue.removeFirst();
    }

    if (queue.length >= maxRequests) {
      return false;
    }

    queue.addLast(now);
    return true;
  }
}
