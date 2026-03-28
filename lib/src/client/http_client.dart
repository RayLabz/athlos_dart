import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import '../core/net/network_logger.dart';
import 'http_client_message_handler.dart';

/// Immutable response payload returned by [HttpClient].
class HttpClientResponseData {
  final int statusCode;
  final String? reasonPhrase;
  final Uint8List body;
  final Map<String, List<String>> headers;

  const HttpClientResponseData({
    required this.statusCode,
    required this.reasonPhrase,
    required this.body,
    required this.headers,
  });

  String get text => utf8.decode(body);

  Map<String, dynamic> json() => jsonDecode(text) as Map<String, dynamic>;
}

/// Represents an HTTP client connected to a server.
class HttpClient {
  /// The address of the server this client will connect to.
  final io.InternetAddress serverAddress;

  /// The port of the server this client will connect to.
  final int serverPort;

  /// The URI scheme used for requests (`http` by default).
  final String scheme;

  /// A callback that will be called when a response is received from the server.
  final HttpClientMessageHandler onMessage;

  /// A callback that will be called periodically to update the client.
  final HttpClientOnTick? onTick;

  /// A callback that will be called when the client starts.
  final Future<void> Function()? onStart;

  /// The interval used to invoke [onTick].
  final Duration tickRate;

  /// Logger used by this client.
  final NetworkLogger logger;

  late final io.HttpClient _client;
  Timer? _tickTimer;

  bool _isStarted = false;
  bool _isClosed = false;

  HttpClient({
    required this.serverAddress,
    required this.serverPort,
    required this.onMessage,
    this.onTick,
    this.onStart,
    this.tickRate = const Duration(milliseconds: 200),
    this.scheme = 'http',
    NetworkLogger? logger,
  }) : logger = logger ?? NetworkLogger();

  /// Starts the client.
  Future<void> start() async {
    if (_isStarted && !_isClosed) {
      return;
    }

    if (onStart != null) {
      await onStart!();
    }

    _client = io.HttpClient();
    _isStarted = true;
    _isClosed = false;

    logger.log(
      'HttpClient',
      'Connected to $scheme://${serverAddress.address}:$serverPort',
    );

    if (onTick != null) {
      _tickTimer = Timer.periodic(tickRate, (_) => onTick!(this));
    }
  }

  /// Sends an HTTP request.
  Future<HttpClientResponseData> request(
    String method,
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Object? body,
  }) async {
    _ensureStarted();

    final uri = Uri(
      scheme: scheme,
      host: serverAddress.address,
      port: serverPort,
      path: _normalizePath(path),
      queryParameters: queryParameters?.isEmpty == true
          ? null
          : queryParameters,
    );

    final request = await _client.openUrl(method.toUpperCase(), uri);

    headers?.forEach(request.headers.set);

    if (body != null) {
      if (body is Uint8List) {
        request.add(body);
      } else if (body is String) {
        request.write(body);
      } else {
        request.headers.contentType ??= io.ContentType.json;
        request.write(jsonEncode(body));
      }
    }

    final response = await request.close();
    final collected = <int>[];

    await for (final chunk in response) {
      collected.addAll(chunk);
    }

    final headersMap = <String, List<String>>{};
    response.headers.forEach((name, values) {
      headersMap[name] = List<String>.from(values);
    });

    final payload = HttpClientResponseData(
      statusCode: response.statusCode,
      reasonPhrase: response.reasonPhrase,
      body: Uint8List.fromList(collected),
      headers: headersMap,
    );

    onMessage(payload);
    return payload;
  }

  /// Sends an HTTP GET request.
  Future<HttpClientResponseData> get(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) {
    return request(
      'GET',
      path,
      headers: headers,
      queryParameters: queryParameters,
    );
  }

  /// Sends an HTTP POST request.
  Future<HttpClientResponseData> post(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Object? body,
  }) {
    return request(
      'POST',
      path,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
    );
  }

  /// Sends an HTTP PUT request.
  Future<HttpClientResponseData> put(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Object? body,
  }) {
    return request(
      'PUT',
      path,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
    );
  }

  /// Sends an HTTP PATCH request.
  Future<HttpClientResponseData> patch(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Object? body,
  }) {
    return request(
      'PATCH',
      path,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
    );
  }

  /// Sends an HTTP DELETE request.
  Future<HttpClientResponseData> delete(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Object? body,
  }) {
    return request(
      'DELETE',
      path,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
    );
  }

  /// Closes the HTTP client.
  Future<void> close() async {
    if (_isClosed) {
      return;
    }

    _isClosed = true;
    logger.log('HttpClient', 'Closing client.');

    _tickTimer?.cancel();
    _tickTimer = null;

    if (_isStarted) {
      _client.close(force: true);
    }

    logger.log(
      'HttpClient',
      'Disconnected from $scheme://${serverAddress.address}:$serverPort',
    );
  }

  void _ensureStarted() {
    if (!_isStarted || _isClosed) {
      throw StateError('HttpClient must be started before sending requests.');
    }
  }

  String _normalizePath(String path) {
    var value = path.trim();

    if (value.isEmpty) {
      return '/';
    }

    if (!value.startsWith('/')) {
      value = '/$value';
    }

    return value;
  }
}
