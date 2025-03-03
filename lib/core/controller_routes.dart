// DARVEL-GENERATED - DO NOT EDIT 2025-03-02 21:19:33.761111
import 'package:shelf/shelf.dart';
import '../app/controllers/AboutController.dart';
import '../app/controllers/HomeController.dart';
import '../app/controllers/UserController.dart';

final Map<String, Function> controllerRoutes = {
  'GET /about-index': (Request request) {
    return AboutController().index(request);
  },
  'GET /about': (Request request) {
    return AboutController().about(request);
  },
  'GET /': (Request request) {
    return HomeController().index(request);
  },
  'GET /home-about': (Request request) {
    return HomeController().about(request);
  },
  'GET /posts/<postId>/comments/<commentId>':
      (Request request, String postId, String commentId) {
    final String? postId = request.url.pathSegments.length > 1
        ? request.url.pathSegments[1]
        : null;
    if (postId == null)
      return Response.badRequest(body: 'Missing required parameter: postId');
    final String? commentId = request.url.pathSegments.length > 2
        ? request.url.pathSegments[2]
        : null;
    if (commentId == null)
      return Response.badRequest(body: 'Missing required parameter: commentId');
    return HomeController().getComment(request, postId, commentId);
  },
  'GET /users': (Request request) {
    return UserController().getUsers(request);
  },
  'GET /user/<id>': (Request request, String id) {
    final String? id = request.url.pathSegments.length > 1
        ? request.url.pathSegments[1]
        : null;
    if (id == null)
      return Response.badRequest(body: 'Missing required parameter: id');
    return UserController().getUser(request, id);
  },
};
