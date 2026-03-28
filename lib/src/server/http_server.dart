import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import '../core/net/network_logger.dart';
import 'http_server_message_handler.dart';

class _RouteKey {
  final String method;
  final String path;

  const _RouteKey(this.method, this.path);

  @override
  bool operator ==(Object other) {
    return other is _RouteKey &&
        other.method == this.method &&
        other.path == this.path;
  }

  @override
  int get hashCode => Object.hash(this.method, this.path);
}

/// Wrapper around [io.HttpRequest] with convenience response helpers.
class HttpRequestContext {
  /// Incoming request associated with this context.
  final io.HttpRequest request;
  bool _closed = false;

  HttpRequestContext(this.request);

  /// Raw response stream for advanced response handling.
  io.HttpResponse get response => request.response;

  /// Whether [close] has already been called.
  bool get isClosed => _closed;

  /// Sends a plain text response and closes the request.
  ///
  /// Use [statusCode] to override the default `200 OK`.
  Future<void> text(String value, {int statusCode = 200}) async {
    response.statusCode = statusCode;
    response.headers.contentType = io.ContentType.text;
    response.write(value);
    await close();
  }

  /// Sends a JSON response and closes the request.
  ///
  /// The [value] is encoded via [jsonEncode].
  /// Use [statusCode] to override the default `200 OK`.
  Future<void> json(Object? value, {int statusCode = 200}) async {
    response.statusCode = statusCode;
    response.headers.contentType = io.ContentType.json;
    response.write(jsonEncode(value));
    await close();
  }

  /// Sends a binary response and closes the request.
  ///
  /// Defaults to `application/octet-stream` when [contentType] is not set.
  /// Use [statusCode] to override the default `200 OK`.
  Future<void> binary(
    Uint8List data, {
    int statusCode = 200,
    io.ContentType? contentType,
  }) async {
    response.statusCode = statusCode;
    response.headers.contentType =
        contentType ?? io.ContentType.binary;
    response.add(data);
    await close();
  }

  /// Reads the full request body as raw binary data.
  ///
  /// This is useful for uploads or arbitrary binary payloads where UTF-8/text
  /// decoding is not appropriate.
  Future<Uint8List> readBinary() async {
    final collected = <int>[];

    await for (final chunk in request) {
      collected.addAll(chunk);
    }

    return Uint8List.fromList(collected);
  }

  /// Closes the HTTP response if it has not already been closed.
  ///
  /// Multiple calls are safe and ignored after the first close.
  Future<void> close() async {
    if (_closed) {
      return;
    }

    _closed = true;
    await response.close();
  }
}

/// Lightweight HTTP server with URL/method routing.
class HttpServer {
  /// Logical server name used as the logging scope.
  final String name;

  /// Host/interface to bind to.
  ///
  /// Defaults to `0.0.0.0` (all available interfaces).
  final String host;

  /// TCP port used by the server.
  final int port;

  /// Logger used for server lifecycle and route events.
  final NetworkLogger logger;

  /// Tick interval used when [onTick] is provided.
  final Duration tickRate;

  /// Optional periodic callback invoked while the server is running.
  final HttpServerOnTick? onTick;

  /// Optional callback invoked before binding and listening.
  final Future<void> Function()? onStart;

  /// Optional fallback handler for unknown routes.
  ///
  /// If omitted, unknown paths return `404` with a JSON error payload.
  final HttpEndpointHandler? onRouteNotFound;

  final Map<_RouteKey, HttpEndpointHandler> _routes = {};
  final Set<String> _registeredPaths = {};

  io.HttpServer? _server;
  StreamSubscription<io.HttpRequest>? _subscription;
  Timer? _tickTimer;

  /// Creates an HTTP server with method+path routing.
  ///
  /// Routes are matched using exact path equality after normalization:
  /// - leading `/` is enforced
  /// - trailing `/` is removed (except root `/`)
  ///
  /// Method names are normalized to uppercase.
  HttpServer({
    this.name = 'AthlosHTTPServer',
    this.host = '0.0.0.0',
    required this.port,
    this.tickRate = const Duration(milliseconds: 200),
    this.onTick,
    this.onStart,
    this.onRouteNotFound,
    NetworkLogger? logger,
  }) : logger = logger ?? NetworkLogger();

  /// Whether the server is currently running.
  bool get isRunning => _server != null;

  /// Starts listening for HTTP requests.
  ///
  /// This method is idempotent; calling it while already running is a no-op.
  Future<void> start() async {
    if (_server != null) {
      return;
    }

    if (onStart != null) {
      await onStart!();
    }

    _server = await io.HttpServer.bind(host, port);
    _subscription = _server!.listen(_handleRequest);

    if (onTick != null) {
      _tickTimer = Timer.periodic(tickRate, (_) => onTick!(this));
    }

    logger.log(name, 'Started on $host:$port');
  }

  /// Stops the server and cancels all active subscriptions/timers.
  ///
  /// This method is idempotent; calling it while stopped is a no-op.
  Future<void> close() async {
    if (_server == null) {
      return;
    }

    logger.log(name, 'Closing server.');

    _tickTimer?.cancel();
    _tickTimer = null;

    await _subscription?.cancel();
    _subscription = null;

    await _server?.close(force: true);
    _server = null;
  }

  /// Registers a `GET` route for [path].
  void get(String path, HttpEndpointHandler handler) {
    route('GET', path, handler);
  }

  /// Registers a `POST` route for [path].
  void post(String path, HttpEndpointHandler handler) {
    route('POST', path, handler);
  }

  /// Registers a `PUT` route for [path].
  void put(String path, HttpEndpointHandler handler) {
    route('PUT', path, handler);
  }

  /// Registers a `PATCH` route for [path].
  void patch(String path, HttpEndpointHandler handler) {
    route('PATCH', path, handler);
  }

  /// Registers a `DELETE` route for [path].
  void delete(String path, HttpEndpointHandler handler) {
    route('DELETE', path, handler);
  }

  /// Registers a route for [method] and [path].
  ///
  /// If the same method/path pair is already registered, the handler is
  /// replaced.
  void route(String method, String path, HttpEndpointHandler handler) {
    final normalizedMethod = method.trim().toUpperCase();
    final normalizedPath = _normalizePath(path);

    _routes[_RouteKey(normalizedMethod, normalizedPath)] = handler;
    _registeredPaths.add(normalizedPath);

    logger.log(name, 'Route registered: $normalizedMethod $normalizedPath');
  }

  /// Removes a route for [method] and [path].
  ///
  /// Returns `true` when a route was removed, otherwise `false`.
  bool removeRoute(String method, String path) {
    final normalizedMethod = method.trim().toUpperCase();
    final normalizedPath = _normalizePath(path);
    final removed = _routes.remove(_RouteKey(normalizedMethod, normalizedPath));

    if (removed == null) {
      return false;
    }

    final hasSamePath = _routes.keys.any((k) => k.path == normalizedPath);
    if (!hasSamePath) {
      _registeredPaths.remove(normalizedPath);
    }

    logger.log(name, 'Route removed: $normalizedMethod $normalizedPath');
    return true;
  }

  Future<void> _handleRequest(io.HttpRequest request) async {
    final method = request.method.toUpperCase();
    final path = _normalizePath(request.uri.path);
    final context = HttpRequestContext(request);

    final handler = _routes[_RouteKey(method, path)];

    if (handler != null) {
      try {
        await handler(context);
      } catch (error) {
        logger.log(name, 'Handler error on $method $path: $error');
        if (!context.isClosed) {
          await context.json({
            'error': 'Internal server error',
          }, statusCode: 500);
        }
      }

      if (!context.isClosed) {
        await context.close();
      }

      return;
    }

    if (_registeredPaths.contains(path)) {
      // Path exists but method does not.
      await context.json({'error': 'Method not allowed'}, statusCode: 405);
      return;
    }

    if (onRouteNotFound != null) {
      await onRouteNotFound!(context);
      if (!context.isClosed) {
        await context.close();
      }
      return;
    }

    await context.json({'error': 'Not found'}, statusCode: 404);
  }

  String _normalizePath(String path) {
    var value = path.trim();

    if (value.isEmpty) {
      return '/';
    }

    if (!value.startsWith('/')) {
      value = '/$value';
    }

    if (value.length > 1 && value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }

    return value;
  }
}
