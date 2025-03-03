// import 'package:shelf/shelf.dart';
// import 'package:shelf_router/shelf_router.dart';
// import 'controller_routes.dart';

// class RouterConfig {
//   Handler get handler {
//     final router = Router();

//     for (final entry in controllerRoutes.entries) {
//       final parts = entry.key.split(' ');
//       final method = parts[0];
//       final path = parts[1];

//       if (method == 'GET') {
//         router.get(path, (Request request) {
//           final params = _extractParamsFromRequest(request, path);
//           return entry.value(request, params);
//         });
//       } else if (method == 'POST') {
//         router.post(path, (Request request) {
//           final params = _extractParamsFromRequest(request, path);
//           return entry.value(request, params);
//         });
//       }
//     }

//     return router;
//   }

//   List<String> _extractParamsFromRequest(Request request, String routePattern) {
//     final requestSegments = request.url.pathSegments;
//     final patternSegments =
//         routePattern.split('/').where((p) => p.isNotEmpty).toList();

//     final params = <String>[];

//     for (int i = 0; i < patternSegments.length; i++) {
//       final segment = patternSegments[i];
//       if (segment.startsWith('<') && segment.endsWith('>')) {
//         params.add(requestSegments[i]);
//       }
//     }

//     return params;
//   }
// }

import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

typedef RouteHandler0 = Future<Response> Function(Request request);
typedef RouteHandler1 = Future<Response> Function(
    Request request, String param1);
typedef RouteHandler2 = Future<Response> Function(
    Request request, String param1, String param2);

class RouterConfig {
  final Map<String, dynamic> controllerRoutes;

  RouterConfig(this.controllerRoutes);

  Handler get handler {
    final router = Router();

    for (final entry in controllerRoutes.entries) {
      final parts = entry.key.split(' ');
      final method = parts[0];
      final path = parts[1];

      if (method == 'GET') {
        router.get(
            path, (Request request) => _handleRequest(entry, request, path));
      } else if (method == 'POST') {
        router.post(
            path, (Request request) => _handleRequest(entry, request, path));
      } else {
        throw UnsupportedError('Método HTTP não suportado: $method');
      }
    }

    return router;
  }

  FutureOr<Response> _handleRequest(
      MapEntry<String, dynamic> entry, Request request, String path) {
    final params = _extractParamsFromRequest(request, path);

    if (params.isEmpty) {
      return (entry.value as dynamic Function(Request))(request);
    } else if (params.length == 1) {
      return (entry.value as dynamic Function(Request, String))(
          request, params[0]);
    } else if (params.length == 2) {
      print(
          'Rota: $path, Params: $params, Handler: ${entry.value.runtimeType}');
      return (entry.value as dynamic Function(Request, String, String))(
          request, params[0], params[1]);
    } else {
      throw StateError('Handler não suporta ${params.length} parâmetros');
    }
  }

  List<String> _extractParamsFromRequest(Request request, String routePattern) {
    final requestSegments = request.url.pathSegments;
    final patternSegments =
        routePattern.split('/').where((p) => p.isNotEmpty).toList();

    final params = <String>[];

    for (int i = 0; i < patternSegments.length; i++) {
      final segment = patternSegments[i];
      if (segment.startsWith('<') && segment.endsWith('>')) {
        params.add(requestSegments[i]);
      }
    }

    return params;
  }
}
