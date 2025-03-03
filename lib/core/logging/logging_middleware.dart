import 'package:shelf/shelf.dart';
import 'logger_service.dart';

Middleware loggingMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      try {
        final response = await innerHandler(request);

        LoggerService.logAccess(
          method: request.method,
          path: request.requestedUri.path,
          headers: request.headers,
          queryParams: request.url.queryParameters,
          statusCode: response.statusCode,
        );

        return response;
      } catch (e, stack) {
        LoggerService.logError('Error handling request: $e', stack);
        return Response.internalServerError(body: 'Internal Server Error');
      }
    };
  };
}
