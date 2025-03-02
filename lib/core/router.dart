// lib/core/router.dart
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'controller_routes.dart';

class RouterConfig {
  Handler get handler {
    final router = Router();

    for (final entry in controllerRoutes.entries) {
      final parts = entry.key.split(' ');
      final method = parts[0];
      final path = parts[1];
      final handler = entry.value;

      if (method == 'GET') {
        router.get(
            path, (Request request) => handler(request, <String, dynamic>{}));
      } else if (method == 'POST') {
        router.post(
            path, (Request request) => handler(request, <String, dynamic>{}));
      }
    }

    return router;
  }
}
