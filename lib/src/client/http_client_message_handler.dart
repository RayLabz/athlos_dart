import 'http_client.dart';

/// A function that is called when a response is received from the HTTP server.
typedef HttpClientMessageHandler =
    void Function(HttpClientResponseData response);

/// A function that is called periodically to update the client.
typedef HttpClientOnTick = void Function(HttpClient client);

