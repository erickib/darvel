// DARVEL-GENERATED - DO NOT EDIT 2025-03-01 23:01:21.105676
import 'package:shelf/shelf.dart';
import '../app/controllers/AboutController.dart';
import '../app/controllers/HomeController.dart';
final Map<String, Function> controllerRoutes = {
  'GET /about-index': (Request request, Map<String, dynamic> services) => AboutController().index(request, services),
  'GET /about': (Request request, Map<String, dynamic> services) => AboutController().about(request, services),
  'GET /': (Request request, Map<String, dynamic> services) => HomeController().index(request, services),
  'GET /home-about': (Request request, Map<String, dynamic> services) => HomeController().about(request, services),
};
