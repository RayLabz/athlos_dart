/// Represents a service that can be used to process requests and generate responses.
abstract class Service<RequestType, ResponseType> {

  /// Processes a request and returns a response.
  ResponseType process(RequestType request);

}