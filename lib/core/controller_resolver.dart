// import 'package:darvel/app/services/UserService.dart';
// import 'package:shelf/shelf.dart';
// import 'package:get_it/get_it.dart';
// import '../core/kernel.dart';

// typedef ControllerMethod = Future<Response> Function(
//     Request request, Map<String, dynamic> services);

// class ControllerResolver {
//   static Future<Response> resolve(
//     dynamic controller,
//     String methodName,
//     Request request,
//   ) async {
//     final method = controllerMethod(controller, methodName);
//     if (method == null) {
//       return Response.internalServerError(
//           body: 'Method $methodName not found on ${controller.runtimeType}');
//     }

//     final services = _resolveDependencies(method);

//     return method(request, services);
//   }

//   static ControllerMethod? controllerMethod(
//       dynamic controller, String methodName) {
//     final methods = <String, ControllerMethod>{
//       'index': controller.index,
//       'about': controller.about,
//     };
//     return methods[methodName];
//   }

//   static Map<String, dynamic> _resolveDependencies(ControllerMethod method) {
//     final services = <String, dynamic>{};
//     // Add any needed services
//     services['UserService'] = Kernel.resolve<UserService>();
//     return services;
//   }
// }
