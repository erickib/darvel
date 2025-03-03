import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf/shelf.dart';
import 'package:darvel/core/router.dart';
import 'package:darvel/core/kernel.dart';
import 'package:darvel/config/app.dart';
import 'package:darvel/core/cli.dart';
import 'package:darvel/core/controller_routes.dart';
import 'package:darvel/core/logging/logging_middleware.dart';

void main(List<String> arguments) async {
  if (arguments.isNotEmpty) {
    Cli.handle(arguments);
    return;
  }
  Kernel.initialize(); // Dependency injection setup

  var handler = const Pipeline()
      .addMiddleware(logRequests()) // Log padrão do shelf (opcional)
      .addMiddleware(loggingMiddleware()) // darvel log
      .addHandler(RouterConfig(controllerRoutes).handler);

  var server = await shelf_io.serve(handler, AppConfig.host, AppConfig.port);
  print('Serving at http://${server.address.host}:${server.port}');
}
