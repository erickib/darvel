import 'package:darvel/core/helpers/response.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'logger_service.dart';
import 'dart:convert';
import '../views/view_renderer.dart';

class InternalLogController {
  Router get router {
    final router = Router();

    // router.get('/darvel/logs/access', (Request request) {
    //   return Response.ok(jsonEncode(LoggerService.accessLogs),
    //       //String accessHtml = PageAccessLogs()
    //       // return Response.ok(
    //       //    accessHtml,
    //       headers: {'Content-Type': 'application/json'});
    // });

    router.get('/darvel/logs/errors', (Request request) {
      return Response.ok(jsonEncode(LoggerService.errorLogs),
          headers: {'Content-Type': 'application/json'});
    });

    router.get('/darvel/logs/clear', (Request request) {
      LoggerService.clear();
      return Response.ok(jsonEncode({'message': 'Logs cleared'}));
    });

    return router;
  }
}
