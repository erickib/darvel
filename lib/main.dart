import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf/shelf.dart';
import 'core/router.dart';
import 'core/kernel.dart';
import 'config/app.dart';

void main() async {
  Kernel.initialize(); // Dependency injection setup

  var handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(RouterConfig().handler);

  var server = await shelf_io.serve(handler, AppConfig.host, AppConfig.port);
  print('Serving at http://${server.address.host}:${server.port}');
}
