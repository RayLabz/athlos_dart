import 'dart:async';

import 'http_server.dart';

/// Handler invoked for matched HTTP routes.
typedef HttpEndpointHandler =
    FutureOr<void> Function(HttpRequestContext context);

/// Optional periodic callback while the HTTP server is running.
typedef HttpServerOnTick = void Function(HttpServer server);
