import 'package:darvel/core/logging/logger_service.dart';
import 'package:darvel/core/helpers/pages.dart';
import 'package:shelf/shelf.dart';

Middleware loggingMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      try {
        final response = await innerHandler(request);

        // If accessing logs page, render it dynamically
        if (request.requestedUri.path == "/darvel/logs/access") {
          String logHtml =
              PageAccessLogs(logs: LoggerService.accessLogs).render();

          return Response.ok(logHtml, headers: {'Content-Type': 'text/html'});
        } else {
          // Log successful request details
          LoggerService.logAccess(
            method: request.method,
            path: request.requestedUri.path,
            headers: request.headers,
            queryParams: request.url.queryParameters,
            statusCode: response.statusCode,
          );
        }
        return response;
      } catch (e, stack) {
        // Log the error
        LoggerService.logError('Error handling request: $e', stack);

        String errorHtml = PageInternalServerError(
          error: e.toString(),
          stack: stack.toString(),
        ).render();
        return Response.internalServerError(
          body: errorHtml,
          headers: {'Content-Type': 'text/html'},
        );
      }
    };
  };
}
